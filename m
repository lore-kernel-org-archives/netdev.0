From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 46/49] net/netfilter: Use vzalloc
Date: Fri, 05 Nov 2010 07:30:40 +0100
Message-ID: <1288938640.3234.12.camel@edumazet-laptop>
References: <alpine.DEB.2.00.1011031108260.11625@router.home>
	 <7d6da34b7e84955795717b0241000a0701cd5b34.1288925425.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jiri Kosina <trivial@kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>, Jesper Juhl <jj@chaosbits.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:33278 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751309Ab0KEGas (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Nov 2010 02:30:48 -0400
In-Reply-To: <7d6da34b7e84955795717b0241000a0701cd5b34.1288925425.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 04 novembre 2010 =C3=A0 20:08 -0700, Joe Perches a =C3=A9crit =
:
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
>  net/netfilter/x_tables.c |    5 ++---
>  1 files changed, 2 insertions(+), 3 deletions(-)

So many 'vzalloc' patches for net tree...=20

I had _one_ patch, waiting that David actually had vzalloc() in its tre=
e
before sending it.

Given Jesper Juhl was doing this work, could you please take another
one, please ?

=46or example, explaining him how to use other tools than "bash+egrep
+manual inspection" as he mentioned in a previous mail.

Really Joe, your behavior should be smarter than that.

Thanks


