# Contributing to LA-Mesh

Thank you for your interest in contributing to LA-Mesh, a community LoRa mesh network for Southern Maine.

---

## Ways to Contribute

### No Technical Skills Required
- Attend community meetups
- Help with site surveys for node placement
- Report coverage gaps or connectivity issues
- Spread the word to neighbors and community members

### Technical Contributions
- Improve documentation
- Add device configuration profiles
- Write curriculum content
- Develop bridge integrations
- Fix bugs or improve tooling

---

## Getting Started

1. Read the [Developer Guide](docs/guides/developing.md)
2. Set up the dev environment: `nix develop` or install tools manually
3. Browse open [issues](https://github.com/Jesssullivan/LA-Mesh/issues) for things to work on
4. Fork the repo and create a feature branch

---

## Pull Request Process

1. Create a branch: `git checkout -b feature/your-feature`
2. Make your changes
3. Run validation: `just check`
4. Commit with a clear message describing what and why
5. Push and open a PR against `main`
6. Fill out the PR template

### PR Checklist

- [ ] Changes are focused (one feature/fix per PR)
- [ ] Documentation updated if needed
- [ ] No credentials or secrets included
- [ ] YAML configs validate
- [ ] Shell scripts pass ShellCheck

---

## Security

**NEVER commit**:
- Channel PSK values
- API keys or tokens
- Private keys
- `.env` files with real credentials

If you accidentally commit a secret, notify the maintainers immediately. The PSK will need to be rotated.

---

## Code of Conduct

LA-Mesh is a community project. Be kind, be patient, be helpful. We're building infrastructure that serves everyone in our community.

---

## Questions?

Open an issue or reach out at a community meetup.
