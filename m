From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH v4 2/3] tg3: make it possible to provide phy_id in
 ioctl
Date: Thu, 7 Feb 2013 08:10:36 -0800
Message-ID: <1360253436.796.58.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <1360251459-32384-1-git-send-email-hauke@hauke-m.de>
 <1360251459-32384-3-git-send-email-hauke@hauke-m.de>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=cp1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, mcarlson@broadcom.com, nsujir@broadcom.com,
	netdev@vger.kernel.org, m@bues.ch
To: "Hauke Mehrtens" <hauke@hauke-m.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3757 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754583Ab3BGQLt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Feb 2013 11:11:49 -0500
In-Reply-To: <1360251459-32384-3-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-02-07 at 16:37 +0100, Hauke Mehrtens wrote:
> In OpenWrt we currently use a switch driver which uses the ioctls to
> configure the switch in the phy. We have to provide the phy_id to do
> so, but without this patch this is not possible.
> 
> Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de> 

Looks good.
Acked-by: Michael Chan <mchan@broadcom.com>
