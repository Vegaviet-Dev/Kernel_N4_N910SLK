make exynos5433-tre_eur_open_16.dtb || exit 1
tools/dtbToolCM -o dt.img -s 2048 -p scripts/dtc/ arch/arm/boot/dts/ || exit 1
