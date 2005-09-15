From: "Alejandro Bonilla" <abonilla@linuxwireless.org>
Subject: RE: ipw2200 using old wireless extensions
Date: Thu, 15 Sep 2005 15:10:57 -0600
Message-ID: <00b501c5ba39$f7cff370$a20cc60a@amer.sykes.com>
References: <4329E09B.9020807@drzeus.cx>
Reply-To: <abonilla@linuxwireless.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750889AbVIOVOH@vger.kernel.org>
To: "'Pierre Ossman'" <drzeus-list@drzeus.cx>,
	"'LKML'" <linux-kernel@vger.kernel.org>,
	"'Netdev List'" <netdev@vger.kernel.org>,
	<ipw2100-admin@linux.intel.com>, <jt@hpl.hp.com>
In-Reply-To: <4329E09B.9020807@drzeus.cx>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> With the inclusion of the ipw2200 driver and the update of
> the wireless
> extensions I get my dmesg flooded with these:
>
> eth0 (WE) : Driver using old /proc/net/wireless support,
> please fix driver !
>
> Somebody please make the hurting go away :)

Yes, we all are aware and getting dmesg spammed with these messages. Even
more if you have a Wireless Monitor applet that reads from the /proc
everytime.

Fix is on the way AFAIK.

.Alejandro
