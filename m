From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 02/11] fs_enet: Add FEC TX Alignment workaround for
 MPC5121
Date: Tue, 19 Jan 2010 20:04:39 -0800 (PST)
Message-ID: <20100119.200439.193706380.davem@davemloft.net>
References: <1263932653-3634-3-git-send-email-agust@denx.de>
	<20100119.123706.12493208.davem@davemloft.net>
	<20100120104225.3361e6c4.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: agust@denx.de, kosmo@semihalf.com, dzu@denx.de,
	netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	jrigby@freescale.com, wd@denx.de
To: sfr@canb.auug.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43837
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752539Ab0ATEEa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jan 2010 23:04:30 -0500
In-Reply-To: <20100120104225.3361e6c4.sfr@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Wed, 20 Jan 2010 10:42:25 +1100

> On Tue, 19 Jan 2010 12:37:06 -0800 (PST) David Miller <davem@davemloft.net> wrote:
>>
>> Well... where are the other 9 patches?
> 
> I think the other 9 are not network related, just PowerPC related.

Ok, but that's very confusing.

If it's meant to go into two different trees split the
patches up into two different series.
