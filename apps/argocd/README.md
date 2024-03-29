<p align="center">
<img width="350" height="250" src="https://cncf-branding.netlify.app/img/projects/argo/horizontal/color/argo-horizontal-color.svg"></br><img src="https://img.shields.io/github/v/release/argoproj/argo-cd?label=Latest%20Version&logo=github&style=for-the-badge">
</p>

### Description

> ArgoCD is a continuous delivery tool for Kubernetes that helps you keep your applications in sync with the desired state that you have defined in git. It uses a declarative configuration file to specify the desired state of your applications, and it continuously monitors the live state of your applications to ensure that they match the desired state.
>
> With ArgoCD, you can easily manage and automate the deployment of your applications, making it easy to keep your applications up-to-date and consistent across different environments.

### Reasons I chose ArgoCD over Flux for this implementation

> - Provides an intuitive web-based user interface that allows you to view and manage the state of your applications, which makes it easier to use and collaborate on with your team. It is
easier to learn how GitOps works, plus, with recent updates, you can both watch Prometheus metrics and open a terminal inside a pod directly from the Argo's client interface.
 > - It also provides an API that allows you to integrate it with other tools and systems, which gives you more flexibility and allows you to automate your continuous delivery workflow. Test how applications could be integrated with it, rather this is rather limited on FluxCD.

- [Website][website-uri]
- [Official Documentation][docs-uri]
- [Awesome ArgoCD][awesome-uri]


### Instructions for deployment

```bash
task argocd:install
```

[website-uri]: https://argoproj.github.io/cd/
[docs-uri]: https://argo-cd.readthedocs.io/en/stable/
[awesome-uri]: https://github.com/terrytangyuan/awesome-argo
