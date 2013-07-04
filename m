From: Jack Morgenstein <jackm@dev.mellanox.co.il>
Subject: Re: [PATCH V2 5/9] IB/mlx5: Mellanox Connect-IB, IB driver part 1/5
Date: Thu, 4 Jul 2013 17:03:53 +0300
Message-ID: <201307041703.54461.jackm@dev.mellanox.co.il>
References: <1372871592-32033-1-git-send-email-ogerlitz@mellanox.com> <1372885168.1886.17.camel@joe-AO722> <201307041615.25729.jackm@dev.mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Or Gerlitz <ogerlitz@mellanox.com>, roland@kernel.org,
	linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net, eli@dev.mellanox.co.il, moshel@mellanox.com,
	Eli Cohen <eli@mellanox.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f169.google.com ([209.85.215.169]:41013 "EHLO
	mail-ea0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751781Ab3GDOCM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jul 2013 10:02:12 -0400
Received: by mail-ea0-f169.google.com with SMTP id h15so827715eak.28
        for <netdev@vger.kernel.org>; Thu, 04 Jul 2013 07:02:10 -0700 (PDT)
In-Reply-To: <201307041615.25729.jackm@dev.mellanox.co.il>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 04 July 2013 16:15, Jack Morgenstein wrote:
> > > +=A0=A0=A0*inlen =3D sizeof **cqb + sizeof *(*cqb)->pas * ncont;
> >=20
> > sizeof always uses parentheses
>=20
I'll fix this, too.

-Jack
