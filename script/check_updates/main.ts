#!/usr/bin/env -S deno run -A

import "@std/dotenv/load";
import * as path from "@std/path";
import * as yaml from "@std/yaml";

interface HelmChart {
  name: string;
  repo?: string;
  version: string;
  releaseName: string;
}

interface Kustomization {
  helmCharts?: HelmChart[];
}

interface BaseComponent {
  name: string;
  sourcePath: string;
  releaseNotes?: string;
}

interface HelmComponent extends BaseComponent {
  type: "helm";
  /// First helm chart is used if unspecified
  releaseName?: string;
}

type Component = HelmComponent;

const helmApp = (
  name: string,
  extra: Omit<HelmComponent, "name" | "type" | "sourcePath"> &
    Pick<Partial<HelmComponent>, "name" | "type" | "sourcePath"> = {},
): HelmComponent =>
  Object.assign(
    { name, type: "helm" as const, sourcePath: `../../apps/${name}` },
    extra,
  );
const components: Component[] = [
  helmApp("argocd", {
    releaseNotes:
      "https://github.com/argoproj/argo-cd/releases https://github.com/argoproj/argo-helm/releases",
  }),
  helmApp("authentik", {
    releaseNotes: "https://docs.goauthentik.io/releases/",
  }),
  helmApp("cert-manager"),
  helmApp("cert-manager-webhook-ovh", {
    releaseNotes: "https://github.com/aureq/cert-manager-webhook-ovh/releases",
  }),
  helmApp("cilium"),
  helmApp("descheduler"),
  helmApp("harbor"),
  helmApp("headlamp", {
    releaseNotes: "https://github.com/kubernetes-sigs/headlamp/releases",
  }),
  helmApp("ingress-mc"),
  helmApp("kubevirt"),
  helmApp("loki", {
    releaseName: "loki",
  }),
  helmApp("loki", {
    releaseName: "alloy",
  }),
  helmApp("openebs", {
    releaseNotes: "https://github.com/openebs/openebs/releases",
    releaseName: "openebs",
  }),
  helmApp("openebs", {
    releaseNotes: "https://github.com/openebs/monitoring/releases",
    releaseName: "monitoring",
    name: "openebs-monitoring",
  }),
  helmApp("postgres", {
    releaseNotes: "https://github.com/cloudnative-pg/cloudnative-pg/releases",
  }),
  helmApp("prometheus-stack"),
  helmApp("rustfs"),
  helmApp("sealed-secrets", {
    releaseNotes: "https://github.com/bitnami/sealed-secrets/releases",
  }),
  helmApp("test-mc"),
  helmApp("user-juan"),
  helmApp("website"),
];

const tasks = components.map(async (component) => {
  (async () => {
    let tags;
    if (component.type === "helm") {
      tags = await process_helm(component);
    }

    console.log(component.name, tags);
  })().catch((error) => {
    console.error(`Unable to process ${component.name}: \n${error}`);
    throw error;
  });
});
await Promise.all(tasks);

async function process_helm(component: HelmComponent) {
  const dataStr = await Deno.readTextFile(
    path.join(component.sourcePath, "kustomization.yaml"),
  );
  const data = yaml.parse(dataStr) as Kustomization;

  const candidateCharts = data.helmCharts?.filter((x) => x.repo != null) ?? [];

  const chart =
    component.releaseName == null
      ? candidateCharts.at(0)
      : candidateCharts.find((x) => x.releaseName === component.releaseName);
  if (chart == null) {
    console.warn(`Can't find helm chart for ${component.name}. Skipping.`);
    return;
  }

  chart.repo = chart.repo?.replace(/\/$/, "");

  if (chart.repo!.startsWith("oci://")) return list_oci_tags(component, chart);
  return list_helm_tags(component, chart);
}

async function list_oci_tags(component: HelmComponent, chart: HelmChart) {
  let url = chart.repo!.replace(/oci:\/\/(.*?)\//, "https://$1/v2/");
  url += `/${chart.name}/tags/list?last=${encodeURIComponent(chart.version)}`;

  let res = await fetch(url);
  if (res.status === 401) {
    const authHeader = res.headers.get("www-authenticate")?.split(" ", 2)[1];
    if (authHeader == null) {
      console.warn(
        `Cant auth against oci for ${component.name} (no www-authenticate)`,
      );
      return;
    }
    const realm = authHeader.match(/realm="(.*?)"/)?.[1];
    if (realm == null) {
      console.warn(`Cant auth against oci for ${component.name} (no realm)`);
      return;
    }
    const scope = authHeader.match(/scope="(.*?)"/)?.[1];
    const service = authHeader.match(/service="(.*?)"/)?.[1];

    const authUrl = new URL(realm);
    if (scope != null) authUrl.searchParams.append("scope", scope);
    if (service != null) authUrl.searchParams.append("service", service);

    const token = await fetch(authUrl)
      .then((res) => res.json())
      .then((data) => data["token"]);

    res = await fetch(url, {
      headers: {
        Authorization: `Bearer ${token}`,
      },
    });
  }

  const resJson = await res.json();
  return (resJson["tags"] ?? []) as string[];
}

async function list_helm_tags(component: HelmComponent, chart: HelmChart) {
  const url = new URL(`${chart.repo}/index.yaml`);
  const data = await fetch(url)
    .then((res) => res.text())
    .then(
      (data) =>
        // deno-lint-ignore no-explicit-any
        yaml.parse(data) as any,
    );
  // deno-lint-ignore no-explicit-any
  let versions = (data["entries"][chart.name] as any[]).map(
    (x) => x["version"],
  ) as string[];
  versions = versions.slice(0, versions.indexOf(chart.version));

  return versions.toReversed();
}
