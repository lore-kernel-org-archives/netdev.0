From: "=?iso-8859-1?q?R=E9mi?= Denis-Courmont" <remi@remlab.net>
Subject: Re: [PATCH net-next-2.6] Phonet: remove dangling pipe if an endpoint is closed early
Date: Thu, 16 Sep 2010 07:41:16 +0300
Message-ID: <201009160741.16973.remi@remlab.net>
References: <1284589193-26089-1-git-send-email-remi@remlab.net> <20100915.213258.212397416.davem@davemloft.net> <20100915.213518.137835427.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:57062 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751404Ab0IPElV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Sep 2010 00:41:21 -0400
In-Reply-To: <20100915.213518.137835427.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

   Hello,

On Thursday 16 September 2010, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Wed, 15 Sep 2010 21:32:58 -0700 (PDT)
>=20
> > Applied.
>=20
> Btw, I had to apply the following warning fix against your other
> set of changes.

Oh yeah, I only have 32-bits systems at hand so ptrdiff_t =3D=3D int fo=
r me :-(
Sorry.

--=20
R=E9mi Denis-Courmont
http://www.remlab.net/
