From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: VLAN 1 - Native
Date: Wed, 01 Feb 2012 22:01:28 +0100
Message-ID: <1328130088.2902.9.camel@edumazet-laptop>
References: <1328095366.10975.YahooMailNeo@web29004.mail.ird.yahoo.com>
	 <1328095449.75127.YahooMailNeo@web29014.mail.ird.yahoo.com>
	 <1328101484.2595.17.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CADDf=MQ8EYEtOO2e5NJLrW0DKDz5xCBEBwuY6rxNu4Cybq=kKQ@mail.gmail.com>
	 <CADDf=MQ=0eadY-zT_YAgp17fo_xRUh0dg6nHCLpNXcMQnUdyCQ@mail.gmail.com>
	 <1328108723.2595.33.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CADDf=MRDa6C47ToCnR3_cTkfJR8VL9UAScwzwGVUDn3O4nL6fA@mail.gmail.com>
	 <1328114680.76107.YahooMailNeo@web29019.mail.ird.yahoo.com>
	 <CADDf=MRuAWRFWMiCOOkWBzhW7_B3wRoMEpmk8ij=SxD2QvP3mw@mail.gmail.com>
	 <1328120055.2541.5.camel@bwh-desktop>
	 <CADDf=MRvCyvEtWGAvPV29uCeoTrDTbjyi0g-q5Qj1zVPDOLYrA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Leonardo Uzcudun <uzcudunl@yahoo.it>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: yao zhao <yao.development@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:58057 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753702Ab2BAVBc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2012 16:01:32 -0500
Received: by wgbdt10 with SMTP id dt10so1764999wgb.1
        for <netdev@vger.kernel.org>; Wed, 01 Feb 2012 13:01:31 -0800 (PST)
In-Reply-To: <CADDf=MRvCyvEtWGAvPV29uCeoTrDTbjyi0g-q5Qj1zVPDOLYrA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 01 f=C3=A9vrier 2012 =C3=A0 15:52 -0500, yao zhao a =C3=A9c=
rit :

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
