From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] cxgb3: fix crash due to manipulating queues before
 registration
Date: Thu, 28 Oct 2010 07:18:30 +0200
Message-ID: <1288243110.2658.126.camel@edumazet-laptop>
References: <1288236563.2658.59.camel@edumazet-laptop>
	 <1288242390-28574-1-git-send-email-nacc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: sonnyrao@us.ibm.com, Divy Le Ray <divy@chelsio.com>,
	Dimitris Michailidis <dm@chelsio.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Nishanth Aravamudan <nacc@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:49301 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754067Ab0J1FSg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 01:18:36 -0400
In-Reply-To: <1288242390-28574-1-git-send-email-nacc@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 27 octobre 2010 =C3=A0 22:06 -0700, Nishanth Aravamudan a =C3=
=A9crit :
> Hi Eric,
>=20
> Something like the following?:
>=20
> Thanks,
> Nish

Yes, probably, but I dont have the hardware so cannot test.


