From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: [PATCH/RFC net] ipv6: fix fragmentation bug
Date: Mon, 4 Nov 2013 10:51:43 +0100
Message-ID: <20131104095142.GB20131@omega>
References: <1383557174-19424-1-git-send-email-alex.aring@gmail.com>
 <1383557174-19424-2-git-send-email-alex.aring@gmail.com>
 <52776B5A.6030701@windriver.com>
 <20131104094303.GA20131@omega>
 <52776D10.4020104@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f180.google.com ([209.85.215.180]:50448 "EHLO
	mail-ea0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752539Ab3KDJvr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Nov 2013 04:51:47 -0500
Received: by mail-ea0-f180.google.com with SMTP id l9so2727725eaj.11
        for <netdev@vger.kernel.org>; Mon, 04 Nov 2013 01:51:46 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <52776D10.4020104@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 04, 2013 at 05:46:56PM +0800, Fan Du wrote:
>=20
>=20
> On 2013=E5=B9=B411=E6=9C=8804=E6=97=A5 17:43, Alexander Aring wrote:
> >Hi,
> >
> >On Mon, Nov 04, 2013 at 05:39:38PM +0800, Fan Du wrote:
> >>>  Hi, Alexander
> >>>
> >>>  I don't know whether which head commit you are sitting, this iss=
ue might has already been fixed by Steffen:
> >>>  https://git.kernel.org/cgit/linux/kernel/git/klassert/ipsec.git/=
commit/?id=3D84502b5ef9849a9694673b15c31bd3ac693010ae
> >>>
> >>>
> >oh I am using current net-next which haven't this fix.
> >
>=20
> Since it's a bug fix, so it's in net tree for the moment...
>=20
Ok, thanks and sorry for the noise...

- Alex
