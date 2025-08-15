#!/bin/bash
sleep 1
nome_pc="$(cat /mnt/etc/hostname)"
if [ -d /sys/firmware/efi ]; then
  firmware="UEFI"
else
  firmware="BIOS"
fi
echo "Firmware: $firmware"
echo "belezinha belezinha, agora é a parte fudida, tá preparado?"
echo "vamo configurar teu refind."
arch-chroot /mnt refind-install
read -p "me dá um nome daora aí pro teu disco de root: " -r nome_root
cat <<EOF >>/mnt/boot/efi/refind/refind.conf

# ---------------------------------------------------------
# Entrada adicionada automaticamente pelo script Ch-aronte
# ---------------------------------------------------------

menuentry "$nome_pc" {
    icon /EFI/refind/icons/os_arch.png
    volume $nome_pc
    loader /vmlinuz-linux
    initrd /initramfs-linux.img
    options "root=LABEL=$nome_root rw add_efi_memmap"
    submenuentry "fallback" {
        initrd /initramfs-linux-fallback.img
    }
    submenuentry "bootar pro terminal" {
        add_options "systemd.unit=multi-user.target"
    }
}
EOF

lsblk
echo ""
read -p "qual era tua partição de root mesmo? " -r root
read -p "e tu usava btrfs ou nem (y/N)? " -r btrfs
if [[ $btrfs == "y" ]]; then
  btrfs filesystem label "/dev/$root" "$nome_root"
else
  e2label "/dev/$root" "$nome_root"
fi
arch-chroot /mnt systemctl enable NetworkManager
echo "Ok, meu trabnalho aqui tá feito, agora é contigo, se vira nos 30. Em teoria, é só reiniciar"
echo "mas se der ruim, aí é contigo, tentei fazer o script redondinho e o mais fácil"
echo "e se der ruim, manda mensagem lá no github que eu vou tentar corrigir o bug, mas vc que tem que identificar o problema"
echo "Obrigado por usar o Ch-aronte, espero que tenha gostado"