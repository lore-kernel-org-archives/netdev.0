From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] CHOKe flow scheduler (0.7)
Date: Thu, 13 Jan 2011 19:02:48 +0100
Message-ID: <1294941768.3570.422.camel@edumazet-laptop>
References: <20110113092706.154748c2@s6510>
	 <1294941621.3570.419.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:48633 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756953Ab1AMSC6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jan 2011 13:02:58 -0500
Received: by wyb28 with SMTP id 28so1969529wyb.19
        for <netdev@vger.kernel.org>; Thu, 13 Jan 2011 10:02:53 -0800 (PST)
In-Reply-To: <1294941621.3570.419.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 13 janvier 2011 =C3=A0 19:00 +0100, Eric Dumazet a =C3=A9crit =
:
> Le jeudi 13 janvier 2011 =C3=A0 09:27 -0800, Stephen Hemminger a =C3=A9=
crit :
> > This implements the CHOKe packet scheduler based on the existing
> > Linux RED scheduler based on the algorithm described in the paper.
> >=20
> >

Sorry for the long reply, I hit 'Send' button in the wrong window,
before removing hunks.



