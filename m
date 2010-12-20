From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Kernel panic eth2 mirred redirect to ifb0
Date: Mon, 20 Dec 2010 12:22:56 +0000
Message-ID: <20101220122256.GA9325@ff.dom.local>
References: <4D0F0D73.2080807@itcare.pl> <AANLkTim1YZd0FgunGKN_YPiLW+uExXajwingUkQeW=a=@mail.gmail.com> <1292836097.2800.3.camel@edumazet-laptop> <AANLkTi=R_ZsYgsYd7EkxHRFTKjtLyLQAOYay2nBV=0bK@mail.gmail.com> <1292836885.2800.4.camel@edumazet-laptop> <20101220103226.GB7977@ff.dom.local> <1292841671.2800.11.camel@edumazet-laptop> <20101220111141.GC7977@ff.dom.local> <20101220115855.GD7977@ff.dom.local> <4D0F471D.8030607@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Changli Gao <xiaosuo@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Network Development list <netdev@vger.kernel.org>
To: =?iso-8859-2?Q?Pawe=B3?= Staszewski <pstaszewski@itcare.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f43.google.com ([209.85.161.43]:36894 "EHLO
	mail-fx0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755491Ab0LTMW7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Dec 2010 07:22:59 -0500
Received: by fxm18 with SMTP id 18so2951305fxm.2
        for <netdev@vger.kernel.org>; Mon, 20 Dec 2010 04:22:58 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <4D0F471D.8030607@itcare.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 20, 2010 at 01:07:57PM +0100, Pawe=B3 Staszewski wrote:
> I have the same panic as without.
>
> This patch was added to clean 2.6.37-rc6 - without previous patch for=
 =20
> sch_generic.h
>
> Attached image with kernel panic.

This one is definitely the nicest ;-)

Thanks,
Jarek P.
