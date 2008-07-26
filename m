From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] net: convert BUG_TRAP to generic WARN_ON
Date: Fri, 25 Jul 2008 21:40:00 -0700 (PDT)
Message-ID: <20080725.214000.202135581.davem@davemloft.net>
References: <E1KMPJS-0005Dh-00@gondolin.me.apana.org.au>
	<20080725.132105.175832134.davem@davemloft.net>
	<Pine.LNX.4.64.0807260003200.11441@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54164
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751028AbYGZEkA convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 26 Jul 2008 00:40:00 -0400
In-Reply-To: <Pine.LNX.4.64.0807260003200.11441@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Sat, 26 Jul 2008 00:19:42 +0300 (EEST)

> Thanks! I thought Herbert patch was related but since I couldn't find=
 it=20
> in your tree I assumed that you volunteer to fix it like you usually =
do=20
> with the other people too who are hit by a merge conflicts due to som=
e=20
> very recent merges. Afterwards I realized that I could have just
> included his patch locally but honestly it was after I made and sent
> that one out... :-)

No worries :)
