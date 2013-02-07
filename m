From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH v4 3/3] tg3: add support for Ethernet core in
 bcm4785
Date: Thu, 7 Feb 2013 08:07:39 -0800
Message-ID: <1360253259.796.54.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <1360251459-32384-1-git-send-email-hauke@hauke-m.de>
 <1360251459-32384-4-git-send-email-hauke@hauke-m.de>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=cp1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, mcarlson@broadcom.com, nsujir@broadcom.com,
	netdev@vger.kernel.org, m@bues.ch
To: "Hauke Mehrtens" <hauke@hauke-m.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3660 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757440Ab3BGQHs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Feb 2013 11:07:48 -0500
In-Reply-To: <1360251459-32384-4-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-02-07 at 16:37 +0100, Hauke Mehrtens wrote: 
> The BCM4785 or sometimes named BMC4705 is a Broadcom SoC which a
> Gigabit 5750 Ethernet core. The core is connected via PCI with the rest
> of the SoC, but it uses some extension.
> 
> This core does not use a firmware or an eeprom.
> 
> Some devices only have a switch which supports 100MBit/s, this
> currently does not work with this driver.
> 
> This patch was original written by Michael Buesch <m@bues.ch> and is in
> OpenWrt for some years now.
> 
> This was tested on a Linksys WRT610N V1 and older versions of this patch
> were tested by other people on different devices.
> 
> Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de> 

Looks good.
Acked-by: Michael Chan <mchan@broadcom.com>
