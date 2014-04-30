From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: Re: [PATCH for v3.15] net: mvmdio: Check for a valid interrupt
 instead of an error
Date: Wed, 30 Apr 2014 13:03:51 -0300
Message-ID: <20140430160351.GA17162@arch.cereza>
References: <1398800999-9814-1-git-send-email-ezequiel.garcia@free-electrons.com>
 <53601B96.3000608@gmail.com>
 <20140430114209.GA1907@arch.cereza>
 <5360FA35.7070209@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Lior Amsalem <alior@marvell.com>,
	Tawfik Bayouk <tawfik@marvell.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-arm-kernel@lists.infradead.org
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:48007 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S933829AbaD3QEe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Apr 2014 12:04:34 -0400
Content-Disposition: inline
In-Reply-To: <5360FA35.7070209@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Apr 30, Sebastian Hesselbarth wrote:
>=20
> As we know about the potential -EPROBE_DEFER now, I suggest to
> deal with it now, too.
>=20
> Can you resend this as v2 with the other patch you mentioned
> squashed in?
>=20

Sure. I did that first, but then wasn't sure about squashing both chang=
es.

Thanks for helping out,
--=20
Ezequiel Garc=EDa, Free Electrons
Embedded Linux, Kernel and Android Engineering
http://free-electrons.com
