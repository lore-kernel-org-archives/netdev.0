From: Leonardo Uzcudun <uzcudunl@yahoo.it>
Subject: Re: VLAN 1 - Native
Date: Wed, 1 Feb 2012 22:01:59 +0000 (GMT)
Message-ID: <1328133719.56475.YahooMailNeo@web29013.mail.ird.yahoo.com>
References: <1328095366.10975.YahooMailNeo@web29004.mail.ird.yahoo.com>  <1328095449.75127.YahooMailNeo@web29014.mail.ird.yahoo.com>  <1328101484.2595.17.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>  <CADDf=MQ8EYEtOO2e5NJLrW0DKDz5xCBEBwuY6rxNu4Cybq=kKQ@mail.gmail.com>  <CADDf=MQ=0eadY-zT_YAgp17fo_xRUh0dg6nHCLpNXcMQnUdyCQ@mail.gmail.com>  <1328108723.2595.33.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>  <CADDf=MRDa6C47ToCnR3_cTkfJR8VL9UAScwzwGVUDn3O4nL6fA@mail.gmail.com>  <1328114680.76107.YahooMailNeo@web29019.mail.ird.yahoo.com>  <CADDf=MRuAWRFWMiCOOkWBzhW7_B3wRoMEpmk8ij=SxD2QvP3mw@mail.gmail.com>  <1328120055.2541.5.camel@bwh-desktop>  <CADDf=MRvCyvEtWGAvPV29uCeoTrDTbjyi0g-q5Qj1zVPDOLYrA@mail.gmail.com> <1328130088.2902.9.camel@edumazet-laptop>
Reply-To: Leonardo Uzcudun <uzcudunl@yahoo.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	yao zhao <yao.development@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm11.bullet.mail.ird.yahoo.com ([77.238.189.64]:31832 "HELO
	nm11.bullet.mail.ird.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754338Ab2BAWCC convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Feb 2012 17:02:02 -0500
In-Reply-To: <1328130088.2902.9.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Guys,

Tested also in Ubuntu 2.6.38-13 and it is not working.
Tomorrow i'll test Michal suggestion and i'll let you know.



----- Messaggio originale -----
Da: Eric Dumazet <eric.dumazet@gmail.com>
A: yao zhao <yao.development@gmail.com>
Cc: Ben Hutchings <bhutchings@solarflare.com>; Leonardo Uzcudun <uzcudu=
nl@yahoo.it>; "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Inviato: Mercoled=EC 1 Febbraio 2012 22:01
Oggetto: Re: VLAN 1 - Native

Le mercredi 01 f=E9vrier 2012 =E0 15:52 -0500, yao zhao a =E9crit :

> > This should work on:
> > 1. Linux 2.6.36 and earlier, if eth0 has VLAN tag offload.
> > 2. Linux 3.2 and later.
> >
> Any reason?

Code was vastly changed by Jesse Gross in 2.6.36, and many adjustements=
,
bug fixes were needed to stabilize the thing.

This is was I suggested to try a recent kernel.

2.6.32 is too old to be discussed on netdev anymore.
