From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH v2] bnx2x: Support for managing RX indirection table
Date: Thu, 17 Feb 2011 14:58:44 +0200
Message-ID: <1297947524.4722.2.camel@lb-tlvb-eilong.il.broadcom.com>
References: <alpine.DEB.2.00.1102161210190.31937@pokey.mtv.corp.google.com>
 <1297933764.2670.20.camel@edumazet-laptop>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Eric Dumazet" <eric.dumazet@gmail.com>,
	"Tom Herbert" <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1762 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751666Ab1BQM7D convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Feb 2011 07:59:03 -0500
In-Reply-To: <1297933764.2670.20.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-02-17 at 01:09 -0800, Eric Dumazet wrote:
> Le mercredi 16 f=C3=A9vrier 2011 =C3=A0 12:27 -0800, Tom Herbert a =C3=
=A9crit :
> > Support fetching and retrieving RX indirection table via ethtool.
> >=20
> > Signed-off-by: Tom Herbert <therbert@google.com>
> > ---
> >  drivers/net/bnx2x/bnx2x.h         |    2 +
> >  drivers/net/bnx2x/bnx2x_ethtool.c |   56 +++++++++++++++++++++++++=
++++++++++++
> >  drivers/net/bnx2x/bnx2x_main.c    |   22 +++++++++++---
> >  3 files changed, 75 insertions(+), 5 deletions(-)
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Acked-by: Eilon Greenstein <eilong@broadcom.com>

Thanks everyone!=20


