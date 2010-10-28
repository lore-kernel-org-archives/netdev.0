From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [PATCH] cxgb3: fix crash due to manipulating queues before
 registration
Date: Wed, 27 Oct 2010 22:23:49 -0700
Message-ID: <20101028052349.GA21144@us.ibm.com>
References: <1288236563.2658.59.camel@edumazet-laptop>
 <1288242390-28574-1-git-send-email-nacc@us.ibm.com>
 <1288243110.2658.126.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: sonnyrao@us.ibm.com, Divy Le Ray <divy@chelsio.com>,
	Dimitris Michailidis <dm@chelsio.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e7.ny.us.ibm.com ([32.97.182.137]:39548 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754067Ab0J1FYB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Oct 2010 01:24:01 -0400
Content-Disposition: inline
In-Reply-To: <1288243110.2658.126.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 28.10.2010 [07:18:30 +0200], Eric Dumazet wrote:
> Le mercredi 27 octobre 2010 =E0 22:06 -0700, Nishanth Aravamudan a =E9=
crit :
> > Hi Eric,
> >=20
> > Something like the following?:
> >=20
> > Thanks,
> > Nish
>=20
> Yes, probably, but I dont have the hardware so cannot test.

Sorry, should have been clearer. I do have the hardware, tested with th=
e
patch, it does work. Wanted to make sure that it made sense to the
maintainers, of course, but:

Tested-by: Nishanth Aravamudan <nacc@us.ibm.com>

Can be added, if needed.

Thanks,
Nish

--=20
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center
