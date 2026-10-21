# RB Style — Pterodactyl Panel CSS theme

A dark navy / electric-blue visual theme starter for Pterodactyl Panel **1.x**.
It styles existing panel pages; it does not add new dashboard widgets or change panel functionality.

## Important
- Back up your panel before installing.
- This installer targets the legacy Pterodactyl 1.x Blade wrapper (`resources/views/templates/wrapper.blade.php`).
- It deliberately stops on Panel 2.x because that version has a different theme system.
- CSS selectors can vary between panel versions. Review the result and uninstall if anything looks wrong.
- Test on a staging panel first if this is a production hosting service.

## Install from your server
Upload this repository to your GitHub account, then run:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/RB-Style/main/install.sh)
```

Replace `YOUR_USERNAME` with your GitHub username. You can also clone the repo and run `sudo bash install.sh`.

## Uninstall
From a cloned copy of the repo:

```bash
sudo bash uninstall.sh
```

The installer saves a timestamped backup of the Blade wrapper and CSS under `/var/www/pterodactyl/.rb-style-backups/`.

## Customize
Edit `public/themes/rb-style/theme.css` in your panel, or edit `theme.css` here and rerun the installer.
