From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] make per interface sysctl entries configurable
Date: Sun, 25 Oct 2009 22:37:19 +0100
Message-ID: <4AE4C50F.7060605@gmail.com>
References: <200910251954.49700.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Benjamin LaHaise <bcrl@lhnet.ca>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Cosmin Ratiu <cratiu@ixiacom.com>, netdev@vger.kernel.org
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:57745 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754159AbZJYVhX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Oct 2009 17:37:23 -0400
In-Reply-To: <200910251954.49700.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Octavian Purdila a =E9crit :
> RFC patches are attached.
>=20
> Another possible approach: add an interface flag and use it to decide=
 whether=20
> we want per interface sysctl entries or not.
>=20

Hmm, could we speedup sysctl instead, adding rbtree or something ?


