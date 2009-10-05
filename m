From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] TCPCT+1: initial SYN exchange with SYNACK data
Date: Mon, 05 Oct 2009 11:22:32 +0200
Message-ID: <4AC9BAD8.7070002@gmail.com>
References: <4AC79905.1030904@gmail.com>	<20091005.002719.146534039.davem@davemloft.net>	<4AC9A714.7060903@gmail.com> <20091005.010630.214808506.davem@davemloft.net> <4AC9AD14.2060500@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:45127 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932391AbZJEJXM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2009 05:23:12 -0400
In-Reply-To: <4AC9AD14.2060500@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

William Allen Simpson a =E9crit :
> This will be widely deployed.  Deployment in DNS root servers is
> expected by December.  It will be hammered with 600,000+ queries per
> minute.  Does that impact your design expectations?
>=20

10.000 queries per second are challenging, definitly worth to study.


I could not find exact RFC number for this new feature.

Could you give us the up2date info ?

http://ietfreport.isoc.org/all-ids/draft-agl-tcpm-sadata-00.txt is expi=
red.

