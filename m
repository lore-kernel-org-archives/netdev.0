From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 00/35]: System Firmware and SMBIOS Support
Date: Fri, 24 Jun 2011 15:40:57 +0200
Message-ID: <201106241540.57952.arnd@arndb.de>
References: <20110623172206.27602.34306.sendpatchset@prarit.bos.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org,
	x86@kernel.org, linux-acpi@vger.kernel.org,
	linux-ide@vger.kernel.org,
	openipmi-developer@lists.sourceforge.net,
	platform-driver-x86@vger.kernel.org, linux-crypto@vger.kernel.org,
	dri-devel@lists.freedesktop.org, lm-sensors@lm-sensors.org,
	linux-i2c@vger.kernel.org, linux-input@vger.kernel.org,
	linux-media@vger.kernel.org, linux-mmc@vger.kernel.org,
	netdev@vger.kernel.org, linux-pci@vger.kernel.org,
	rtc-linux@googlegroups.com, evel@driverdev.osuosl.org,
	linux-usb@vger.kernel.org,
	device-drivers-devel@blackfin.uclinux.org,
	linux-watchdog@vger.kernel.org, grant.likely@secretlab.ca,
	dz@debian.org, rpurdie@rpsys.net, eric.piel@tremplin-utc.net,
	abelay@mit.edu, johnpol@2ka.mipt.ru
To: Prarit Bhargava <prarit@redhat.com>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <20110623172206.27602.34306.sendpatchset@prarit.bos.redhat.com>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 23 June 2011 19:22:06 Prarit Bhargava wrote:
> This new patchset reworks the existing DMI code into two separate layers.  It is
> based off of the feedback I received previously when discussing the SMBIOS
> version patch on LKML.

Hi Prarit,

No objections to the patches, but when you send out a series as long as
this one, please ensure that all patches are sent as replies to the
introductory mail. Also, do not repeat the one-line patch summary in the
body of the email.

When using "git send-email --thread --no-chain-reply", this works
automatically. It will also let you put the Cc list into the
patch description and work out where to send each patch.

	Arnd
