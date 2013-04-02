From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Bug#565404: linux-image-2.6.26-2-amd64: atl1e: TSO is broken
Date: Tue, 2 Apr 2013 11:41:02 +0200
Message-ID: <20130402094102.GD4924@order.stressinduktion.org>
References: <CDAFEDABF718A54BABD0DA5476695307475CCFF8@SHEXMB-01.global.atheros.com> <20100126.093439.651115405791675606.anders@netinsight.net> <1364689558.3557.22.camel@deadeye.wl.decadent.org.uk> <20130402.093504.1785848735327620554.anders@netinsight.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ben@decadent.org.uk, Jie.Yang@Atheros.com, netdev@vger.kernel.org,
	565404@bugs.debian.org, Xiong.Huang@Atheros.com
To: Anders =?utf-8?Q?Bostr=C3=B6m?= <anders@netinsight.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:45441 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758089Ab3DBJlE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Apr 2013 05:41:04 -0400
Content-Disposition: inline
In-Reply-To: <20130402.093504.1785848735327620554.anders@netinsight.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 02, 2013 at 09:35:04AM +0200, Anders Bostr=C3=B6m wrote:
> I'm sorry, but I can't test this at the moment. The computer with the
> TSO-problem is running as a file-server =3D> can't be used for testin=
g.
> Also, we don't use the Atheros Ethernet interface any more due to
> other problems, hard hang (need reset) of the Eth-interface
> every ~6 month's.

The bug is definitely still around. Yesterday I could reproduce it and =
will
look for a solution in the next days.

Do you have any details on the hangs every 6 months? Could you catch
thread dumps or oopses?

Thanks,

  Hannes
