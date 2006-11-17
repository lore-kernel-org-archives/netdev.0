From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH 3/10][NETLABEL]: Use kmemdup in cipso_ipv4.c
Date: Fri, 17 Nov 2006 12:48:34 -0500
Message-ID: <455DF5F2.30704@hp.com>
References: <20061117151711.GD17958@mandriva.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel8.hp.com ([156.153.255.206]:55178 "EHLO atlrel8.hp.com")
	by vger.kernel.org with ESMTP id S933747AbWKQRsg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Nov 2006 12:48:36 -0500
To: Arnaldo Carvalho de Melo <acme@mandriva.com>
In-Reply-To: <20061117151711.GD17958@mandriva.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arnaldo Carvalho de Melo wrote:
> Code diff stats:
> 
> [acme@newtoy net-2.6.20]$ codiff /tmp/cipso_ipv4.o.before /tmp/cipso_ipv4.o.after
> /pub/scm/linux/kernel/git/acme/net-2.6.20/net/ipv4/cipso_ipv4.c:
>   cipso_v4_cache_add |  -46
>  1 function changed, 46 bytes removed
> [acme@newtoy net-2.6.20]$
> 
> Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

Acked-by: Paul Moore <paul.moore@hp.com>

Looks fine to me.

-- 
paul moore
linux security @ hp
