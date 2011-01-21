From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: Re: MultiPath TCP in the Linux Kernel
Date: Fri, 21 Jan 2011 14:26:12 +0100
Message-ID: <201101211426.12278.christoph.paasch@uclouvain.be>
References: <201101201509.34536.christoph.paasch@uclouvain.be> <7e28a5ddc16848dcd98c05351113304f@localhost> <1295538176.2825.311.camel@edumazet-laptop>
Reply-To: christoph.paasch@uclouvain.be
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hagen Paul Pfeifer <hagen@jauu.net>, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net, linux-sctp@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:58021 "EHLO
	smtp2.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753172Ab1AUN0b convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Jan 2011 08:26:31 -0500
In-Reply-To: <1295538176.2825.311.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thursday, January 20, 2011 wrote Eric Dumazet:
> > if you want that your work becomes part of the official network sta=
ck you
> > should align your effort on the official Linux way. This means you =
should
> > split your work and publish patches on this maillinglist.
>=20
> Hmm, they probably know that, and prefer to wait MTCP stuff is mature
> before patch submission :)
Exactly... :)

The protocol specification of MPTCP is not stable yet=20
(http://datatracker.ietf.org/doc/draft-ietf-mptcp-multiaddressed/).

Also, all the features are not yet in our implementation (e.g., IPv6-su=
pport=20
and dual IPv4/IPv6-support), and it is necessary to make our implementa=
tion=20
less intrusive to the regular TCP/IP-stack.

However, as developper-resources are limited this will still take quite=
 some=20
time... ;)

Cheers,
Christoph


--
Christoph Paasch
PhD Student

IP Networking Lab --- http://inl.info.ucl.ac.be
MultiPath TCP in the Linux Kernel --- http://inl.info.ucl.ac.be/mptcp
Universit=C3=A9 Catholique de Louvain

www.rollerbulls.be
--
