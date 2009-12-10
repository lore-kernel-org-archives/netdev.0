From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net-ipv4-tcp.c-fix-warning-from-older-compilers.patch
Date: Thu, 10 Dec 2009 13:46:13 -0800 (PST)
Message-ID: <20091210.134613.91416472.davem@davemloft.net>
References: <4B20FC2E.7050809@gmail.com>
	<4B2102B4.7050702@gmail.com>
	<4B211452.40600@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp-2
Content-Transfer-Encoding: 7bit
Cc: william.allen.simpson@gmail.com, akpm@linux-foundation.org,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33929
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1761767AbZLJVqG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2009 16:46:06 -0500
In-Reply-To: <4B211452.40600@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 10 Dec 2009 16:31:30 +0100

> Le 10/12/2009 15:16, William Allen Simpson a écrit :
>> Replace + net-ipv4-tcpc-fix-warning.patch added to -mm tree
>> 
>> Remove the offending code, and replace with comments.  This is an
>> unlikely problem, so depend on human finding any future error.
>> 
>> Signed-off-by: William.Allen.Simpson@gmail.com
>> ---
>>  net/ipv4/tcp.c |    9 ++++-----
>>  1 files changed, 4 insertions(+), 5 deletions(-)
> 
> This is not necessary, David already _did_ the thing, and _told_ so.

Right.

> You probably missed fact we are in merge window, so fixes (and only fixes)
> are pushed into net-2.6 tree.

I even announced this explicitly to the list:

	http://marc.info/?l=linux-netdev&m=126031591420846&w=2
