From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [Patch] Establishing more than 64K outgoing TCP connections
Date: Fri, 07 Nov 2008 17:23:01 +0100
Message-ID: <49146B65.5030504@cosmosbay.com>
References: <241CE5A1B2AFFA4987A663380D74C0BB3FD69B08A7@MBX73.ad2.softcom.biz> <20081101.211541.182428064.davem@davemloft.net>,<200811071036.44215.remi.denis-courmont@nokia.com> <241CE5A1B2AFFA4987A663380D74C0BB3FFD15887E@MBX73.ad2.softcom.biz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-1?Q?R=E9mi_Denis-Courmont?=
	<remi.denis-courmont@nokia.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Yavor Goulishev <yavor@simplifymedia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:35024 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751568AbYKGQYF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Nov 2008 11:24:05 -0500
In-Reply-To: <241CE5A1B2AFFA4987A663380D74C0BB3FFD15887E@MBX73.ad2.softcom.biz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please dont top post your messages on this list.

Yavor Goulishev a =E9crit :
> Hey,
> I"m not kernel hacker and I don't want to be.
> I stumbled on something and I fixed it.
> That's not my focus or interest.
> I've spend  a couple of hours on it, just to unblock my project.
> That's all.
>=20
> What was a complete surprise for me was fact that
> something so fundamental can be broken for so long.
> After wasting some time on your mailing list I know
> that it is not technical issue.

Thats the deal.

You post a patch, other people comment on it, and if its good,
patch is accepted. Linux kernel developement is not an easy task.
Not being a "kernel hacker" wont allow you to bypass the rules.

As many people are concerned, its even more important to adopt
a right attitude, because if people are upset, they wont even
consider your patch. Yes, thats a pity.

Your concern is valid, but your patch in its current form
is not *the* solution.

About your idea of having a hash (port , IP), it is not
applicable. If you believe I am wrong, please post
a new patch so that truth can be revealed.


