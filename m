From: Ingo Oeser <netdev@axxeo.de>
Subject: Re: [PATCH] expose simplified skb_checksum_recalc
Date: Thu, 11 May 2006 20:40:32 +0200
Message-ID: <200605112040.32624.netdev@axxeo.de>
References: <446259A0.8050504@myri.com> <200605111924.33125.netdev@axxeo.de> <20060511112843.6532bddd@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Ingo Oeser <ioe-lkml@rameria.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.axxeo.de ([82.100.226.146]:21979 "EHLO mail.axxeo.de")
	by vger.kernel.org with ESMTP id S1750833AbWEKSko (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 May 2006 14:40:44 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060511112843.6532bddd@localhost.localdomain>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Stephen,

Stephen Hemminger wrote:
> Many users of skb_checksum_help() are just using it to recalculate
> outbound checksum, so why not expose the interface in a more useful
> way. Suggested by Ingo Oeser.

You are damn fast Stephen :-)

That's even better and improves a lot on documentation and
code placement for free.


Thanks & Regards

Ingo Oeser
