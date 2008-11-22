From: David Miller <davem@davemloft.net>
Subject: Re: [Pull request] WAN aka generic HDLC (net-next)
Date: Fri, 21 Nov 2008 21:46:38 -0800 (PST)
Message-ID: <20081121.214638.190162060.davem@davemloft.net>
References: <m3ljvcqzhl.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: khc@pm.waw.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39077
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751906AbYKVFqi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Nov 2008 00:46:38 -0500
In-Reply-To: <m3ljvcqzhl.fsf@maximus.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krzysztof Halasa <khc@pm.waw.pl>
Date: Sat, 22 Nov 2008 03:13:42 +0100

> Can you pull my WAN tree into net-next, please?
> Freshly rebased, with duplicate "dev->priv" commits removed, this is
> basically:
> - updates to Hitachi/Renesas SCA/SCA-II-based drivers (including
>   hd6457x.c split into hd64570.c and hd64572.c)
> - the second=last part of syncppp conversion (all drivers are already
>   using hdlc_ppp)
> - smaller things

Pulled, thanks Krzysztof.
