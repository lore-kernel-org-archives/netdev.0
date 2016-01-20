From: Bert Kenward <bkenward@solarflare.com>
Subject: Re: [PATCH] sfc: Replace memset with eth_zero_addr
Date: Wed, 20 Jan 2016 09:44:30 +0000
Message-ID: <569F56FE.6070303@solarflare.com>
References: <1453246074-1054-1-git-send-email-tanure@linux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Lucas Tanure <tanure@linux.com>,
	Shradha Shah <sshah@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo04.seg.att.com ([209.65.160.86]:15680 "EHLO
	nbfkord-smmo04.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932998AbcATJoj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2016 04:44:39 -0500
In-Reply-To: <1453246074-1054-1-git-send-email-tanure@linux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 19/01/16 23:27, Lucas Tanure wrote:
> Use eth_zero_addr to assign the zero address to the given address array
> instead of memset when second argument is address of zero.
> 
> Signed-off-by: Lucas Tanure <tanure@linux.com>
> ---

Acked-by: Bert Kenward <bkenward@solarflare.com>

... although net-next is still closed I think.

-- 
Bert Kenward <bkenward@solarflare.com>
Software Engineer, Solarflare
