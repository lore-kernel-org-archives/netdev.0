From: "Zhu, Yi" <yi.zhu@intel.com>
Subject: RE: [netdrvr] netdev-2.6 queue updated
Date: Mon, 15 Nov 2004 17:34:00 +0800
Message-ID: <3ACA40606221794F80A5670F0AF15F8403BD583B@pdsmsx403>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <akpm@osdl.org>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261479AbUKOJeT@vger.kernel.org>
Content-class: urn:content-classes:message
To: "Jeff Garzik" <jgarzik@pobox.com>, <netdev@oss.sgi.com>,
	<linux-kernel@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> The most notable thing is the addition of HostAP.

How about move HostAP 802.11 stack and crypt related files to
net/80211? It is generic and some other drivers (i.e. ipw2100) share
the code. Do you receive patches to do this?

Thanks,
-yi
