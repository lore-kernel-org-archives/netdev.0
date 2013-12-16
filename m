From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCHv2 net-next 3/3] xfrm: Add file to document IPsec corner
 case
Date: Mon, 16 Dec 2013 11:06:52 +0100
Message-ID: <20131216100652.GG31491@secunet.com>
References: <1387099194-18540-1-git-send-email-fan.du@windriver.com>
 <1387099194-18540-4-git-send-email-fan.du@windriver.com>
 <20131216094622.GF31491@secunet.com>
 <52AECEDA.80403@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:53231 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752291Ab3LPKGz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Dec 2013 05:06:55 -0500
Content-Disposition: inline
In-Reply-To: <52AECEDA.80403@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 16, 2013 at 05:58:50PM +0800, Fan Du wrote:
>=20
>=20
> On 2013=E5=B9=B412=E6=9C=8816=E6=97=A5 17:46, Steffen Klassert wrote:
> >On Sun, Dec 15, 2013 at 05:19:54PM +0800, Fan Du wrote:
> >>+
> >>+One workaround is try to set "level use" for each policy if user o=
bserved
>                   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ here
>=20
> >>+above scenario. The consequence of doing so is small packet(uncomp=
ressed)
> >>+will skip policy checking on receiver side.
> >>+
> >>+
> >
> >Please remove the empty lines at the end of the file.
> >
> >Also, it might be good to mention what the user exactly
> >has configure do to get a workaround.
>     It's in above here..
>=20

Ok.
