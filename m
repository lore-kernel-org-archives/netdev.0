From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference at
 000000000000002c
Date: Fri, 3 Feb 2012 07:53:09 -0800
Message-ID: <20120203155309.GB20638@kroah.com>
References: <20120201.162157.880976652659067010.davem@davemloft.net>
 <4F2A87B0.6070900@profihost.ag>
 <1328195055.2279.61.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <20120202.143957.2251106530056768980.davem@davemloft.net>
 <20120203004228.GA23429@kroah.com>
 <4F2B8348.3090305@profihost.ag>
 <1328253972.2480.42.camel@edumazet-laptop>
 <4F2B963F.4020504@profihost.ag>
 <1328267097.2157.17.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>,
	David Miller <davem@davemloft.net>, jwboyer@gmail.com,
	hch@infradead.org, netdev@vger.kernel.org, david@fromorbit.com,
	stable@vger.kernel.org, gregkh@suse.de
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:47261 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754938Ab2BCPyo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2012 10:54:44 -0500
Received: from compute3.internal (compute3.nyi.mail.srv.osa [10.202.2.43])
	by gateway1.nyi.mail.srv.osa (Postfix) with ESMTP id 81D2F21088
	for <netdev@vger.kernel.org>; Fri,  3 Feb 2012 10:54:44 -0500 (EST)
Content-Disposition: inline
In-Reply-To: <1328267097.2157.17.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 03, 2012 at 12:04:57PM +0100, Eric Dumazet wrote:
> Le vendredi 03 f=E9vrier 2012 =E0 09:09 +0100, Stefan Priebe - Profih=
ost AG
> a =E9crit :
> > Hi,
> >=20
> > attached you find the patch files applying cleanly to 3.0.X.
>=20
> First, thanks a lot for doing this work.
>=20
> OK, lets try to provide a cumulative patch with a good Changelog ?

Individual patches are also ok, if they build properly :)

thanks,

greg k-h
