From: John Heffner <jheffner@psc.edu>
Subject: Re: TCP's initial cwnd setting correct?...
Date: Wed, 08 Aug 2007 11:26:18 -0400
Message-ID: <46B9E09A.3060402@psc.edu>
References: <Pine.LNX.4.64.0708061508070.8788@kivilampi-30.cs.helsinki.fi> <Pine.LNX.4.64.0708062129440.29123@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.psc.edu ([128.182.58.100]:65514 "EHLO mailer1.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759098AbXHHPbb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Aug 2007 11:31:31 -0400
In-Reply-To: <Pine.LNX.4.64.0708062129440.29123@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

That sounds right to me.

   -John


Ilpo J=E4rvinen wrote:
> On Mon, 6 Aug 2007, Ilpo J=E4rvinen wrote:
>=20
>> ...Goto logic could be cleaner (somebody has any suggestion for bett=
er=20
>> way to structure it?)
>=20
> ...I could probably move the setting of snd_cwnd earlier to avoid=20
> this problem if this seems a valid fix at all.
>=20

