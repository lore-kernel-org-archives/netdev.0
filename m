From: =?utf-8?B?SsO2cm4=?= Engel <joern@logfs.org>
Subject: Re: [BUG] New Kernel Bugs
Date: Tue, 13 Nov 2007 23:24:14 +0100
Message-ID: <20071113222414.GD20167@lazybastard.org>
References: <20071113.033946.114918709.davem@davemloft.net> <20071113034916.2556edd7.akpm@linux-foundation.org> <20071113.035824.40509981.davem@davemloft.net> <20071113041259.79c9a8c5.akpm@linux-foundation.org> <20071113134029.GA30978@elte.hu> <4739AFE0.20705@rtr.ca> <20071113193750.GD1356@flint.arm.linux.org.uk> <473A067F.3090007@rtr.ca> <20071113213358.GC20167@lazybastard.org> <20071113135658.5c9ac7ba.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?utf-8?B?SsO2cm4=?= Engel <joern@logfs.org>,
	Mark Lord <liml@rtr.ca>, Ingo Molnar <mingo@elte.hu>,
	alsa-devel@alsa-project.org, netdev@vger.kernel.org,
	linux-pcmcia@lists.infradead.org, linux-kernel@vger.kernel.org,
	protasnb@gmail.com, linux-ide@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	linux-input@atrey.karlin.mff.cuni.cz,
	David Miller <davem@davemloft.net>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lazybastard.de ([212.112.238.170]:39312 "EHLO
	longford.lazybastard.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759082AbXKMW3W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2007 17:29:22 -0500
Content-Disposition: inline
In-Reply-To: <20071113135658.5c9ac7ba.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 13 November 2007 13:56:58 -0800, Andrew Morton wrote:
>=20
> It's relatively common that a regression in subsystem A will manifest=
 as a
> failure in subsystem B, and the report initially lands on the desk of=
 the
> subsystem B developers.
>=20
> But that's OK.  The subsystem B people are the ones with the expertis=
e to
> be able to work out where the bug resides and to help the subsystem A
> people understand what went wrong.
>=20
> Alas, sometimes the B people will just roll eyes and do nothing becau=
se
> they know the problem wasn't in their code.  Sometimes.

And sometimes the A people will ignore the B people after the root caus=
e
has been worked out.  Do you have a good idea how to shame A into
action?  Should I put you on Cc:?  Right now I'm in the eye-rolling
phase.

J=C3=B6rn

--=20
The cost of changing business rules is much more expensive for software
than for a secretaty.
-- unknown
