From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] macb: straighten out macb_mii_probe
 function
Date: Fri, 12 Feb 2010 11:39:25 -0800 (PST)
Message-ID: <20100212.113925.249605315.davem@davemloft.net>
References: <20100208151207.GE2601@psychotron.lab.eng.brq.redhat.com>
	<20100210151706.6f12d431@hskinnemoen-d830>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jpirko@redhat.com, netdev@vger.kernel.org, hskinnemoen@atmel.com
To: haavard.skinnemoen@atmel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57011
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756568Ab0BLTjL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Feb 2010 14:39:11 -0500
In-Reply-To: <20100210151706.6f12d431@hskinnemoen-d830>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Haavard Skinnemoen <haavard.skinnemoen@atmel.com>
Date: Wed, 10 Feb 2010 15:17:06 +0530

> Jiri Pirko <jpirko@redhat.com> wrote:
>> Use "phy_find_first" instead of manual lookup. Also use "phy_connect_direct"
>> instead of "phy_connect" since we already have phy_device pointer here.
>> 
>> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
> 
> Looks reasonable as far as I can see.
> 
> Acked-by: Haavard Skinnemoen <haavard.skinnemoen@atmel.com>

Applied, thanks guys.
