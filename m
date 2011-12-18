From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: bnx2x firmware version 6.x.y
Date: Sun, 18 Dec 2011 11:21:17 +0200
Message-ID: <1324200077.26549.2.camel@lb-tlvb-eilong.il.broadcom.com>
References: <1324140746.2825.335.camel@deadeye>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Dmitry Kravkov" <dmitry@broadcom.com>,
	"Vladislav Zolotarov" <vladz@broadcom.com>,
	LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	"David Woodhouse" <dwmw2@infradead.org>
To: "Ben Hutchings" <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3008 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750979Ab1LRJVh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Dec 2011 04:21:37 -0500
In-Reply-To: <1324140746.2825.335.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2011-12-17 at 08:52 -0800, Ben Hutchings wrote:
> In general, linux-firmware includes all blobs that any released version
> of a driver may need.
> 
> Therefore, I'm about to add the bnx2x firmware versions 6.0.34.0,
> 6.2.5.0 and 6.2.9.0 (taken from kernel versions 2.6.37, 2.6.38 and 3.0
> respectively) into linux-firmware.

Ben - Thanks for doing that.
Acked-by: Eilon Greenstein <eilong@broadcom.com>

> 
> The full lists of bnx2x firmware blobs that will be included after this
> is:
> 
> bnx2x-e1-4.8.53.0.fw
> bnx2x-e1-5.2.13.0.fw
> bnx2x-e1-5.2.7.0.fw
> bnx2x-e1h-4.8.53.0.fw
> bnx2x-e1h-5.2.13.0.fw
> bnx2x-e1h-5.2.7.0.fw
> bnx2x/bnx2x-e1-6.0.34.0.fw
> bnx2x/bnx2x-e1-6.2.5.0.fw
> bnx2x/bnx2x-e1-6.2.9.0.fw
> bnx2x/bnx2x-e1-7.0.20.0.fw
> bnx2x/bnx2x-e1-7.0.23.0.fw
> bnx2x/bnx2x-e1-7.0.29.0.fw
> bnx2x/bnx2x-e1h-6.0.34.0.fw
> bnx2x/bnx2x-e1h-6.2.5.0.fw
> bnx2x/bnx2x-e1h-6.2.9.0.fw
> bnx2x/bnx2x-e1h-7.0.20.0.fw
> bnx2x/bnx2x-e1h-7.0.23.0.fw
> bnx2x/bnx2x-e1h-7.0.29.0.fw
> bnx2x/bnx2x-e2-6.0.34.0.fw
> bnx2x/bnx2x-e2-6.2.5.0.fw
> bnx2x/bnx2x-e2-6.2.9.0.fw
> bnx2x/bnx2x-e2-7.0.20.0.fw
> bnx2x/bnx2x-e2-7.0.23.0.fw
> bnx2x/bnx2x-e2-7.0.29.0.fw
> 
> Ben.
> 
