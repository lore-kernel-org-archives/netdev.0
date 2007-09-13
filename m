From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [BUG] tg3 cannot do PXE (loses MAC address) after soft
 reboot
Date: Thu, 13 Sep 2007 11:05:01 -0700
Message-ID: <1189706701.9540.84.camel@dell>
References: <20070913083918.GA5386@xanadu.blop.info>
 <1551EAE59135BE47B544934E30FC4FC002AABA5B@nt-irva-0751.brcm.ad.broadcom.com>
 <20070913154110.GA25781@xanadu.blop.info>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev" <netdev@vger.kernel.org>
To: "Lucas Nussbaum" <lucas.nussbaum@imag.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3423 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751541AbXIMRHp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Sep 2007 13:07:45 -0400
In-Reply-To: <20070913154110.GA25781@xanadu.blop.info>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-09-13 at 17:41 +0200, Lucas Nussbaum wrote:

> # ethtool -i eth0
> driver: tg3
> version: 3.65
> firmware-version: 5703-v2.21a
> bus-info: 0000:02:02.0

The firmware is quite old and needs to be upgraded to fix the problem.
I'll have someone contact you to get it upgraded.

> 
> What do you mean by "what machine" ? The systems are Dell PowerEdge
> 1600SC, but the NICs were bought separately AFAIK.

I assumed the device was on-board which would normally require a BIOS
upgrade.  For NICs, it's easier.

