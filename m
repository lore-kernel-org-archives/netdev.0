From: Pierre Ossman <drzeus-list@drzeus.cx>
Subject: ipw2200 using old wireless extensions
Date: Thu, 15 Sep 2005 22:59:07 +0200
Message-ID: <4329E09B.9020807@drzeus.cx>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1161024AbVIOU7N@vger.kernel.org>
To: LKML <linux-kernel@vger.kernel.org>,
	Netdev List <netdev@vger.kernel.org>,
	ipw2100-admin@linux.intel.com, jt@hpl.hp.com
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With the inclusion of the ipw2200 driver and the update of the wireless
extensions I get my dmesg flooded with these:

eth0 (WE) : Driver using old /proc/net/wireless support, please fix driver !

Somebody please make the hurting go away :)

Rgds
Pierre
