From: Pascal GREGIS <pgs@synerway.com>
Subject: Re: Connection reset by peer - need a patch
Date: Fri, 27 Feb 2009 17:06:32 +0100
Message-ID: <20090227160632.GF2796@venus.synerway.com>
References: <20090227150755.GE2796@venus.synerway.com> <20090227.072808.98120102.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.synerway.com ([84.14.10.249]:45515 "EHLO
	kamino.synerway.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753434AbZB0QGe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2009 11:06:34 -0500
Content-Disposition: inline
In-Reply-To: <20090227.072808.98120102.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ok, thank you for your answer. Would you have a hint to help me track t=
his bug ?

Pascal

David Miller a =E9crit, le ven 27 f=E9v 2009 =E0 07:28:08 :
> From: Pascal GREGIS <pgs@synerway.com>
> Date: Fri, 27 Feb 2009 16:07:55 +0100
>=20
> > Right, but the problem is that I use a kernel 2.6.21.1 and cannot
> > upgrade my whole kernel easily.  And in the kernel 2.6.21.1, networ=
k
> > namespaces don't seem to exist, so I cannot apply this simple patch=
=2E
>=20
> You're chasing a different bug then, the bug was introduced
> by a network namespace patch so 2.6.21 can't possibly have
> that bug.
