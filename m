From: "Alejandro Bonilla" <abonilla@linuxwireless.org>
Subject: IPW2100 Kconfig
Date: Tue, 6 Sep 2005 12:32:11 -0600
Message-ID: <005101c5b311$4ca69a50$a20cc60a@amer.sykes.com>
Reply-To: <abonilla@linuxwireless.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750790AbVIFScN@vger.kernel.org>
To: <netdev@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

	I checked the IPW2100 in the current git from linux-2.6 and the menuconfig
help (Kconfig) says you need to put the firmware in /etc/firmware, it should
be /lib/firmware.

Who should I send the "patch" to? Or can someone simply change that?

Thanks,

.Alejandro
