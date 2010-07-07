From: =?UTF-8?Q?R=C3=A9mi_Denis-Courmont?= <remi@remlab.net>
Subject: Re: Kernel bug 14839: Trying to use a TUN device for IPv6 traffic, cannot
 set destination address.
Date: Wed, 07 Jul 2010 17:25:01 +0200
Message-ID: <4d0194fe8536c59196233b56548b0314@chewa.net>
References: <846562.91258.qm@web113913.mail.gq1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Ian Shorter <mcisho@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:35512 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756153Ab0GGPZC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Jul 2010 11:25:02 -0400
In-Reply-To: <846562.91258.qm@web113913.mail.gq1.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 7 Jul 2010 08:04:33 -0700 (PDT), Ian Shorter <mcisho@yahoo.com>=
=0D
wrote:=0D
> I reported this kernel bug at the end of 2009. In February 2010 Steph=
en=0D
> Hemminger said that the problem was not unique to TUN, and that I sho=
uld=0D
> bring it up on the network maintainers mailing list, which I am final=
ly=0D
> doing. Do I need to provide the problem description again?=0D
=0D
I really do not see the point of setting a destination address on a TUN=
=0D
device. Since a TUN device has no link-layer, the notions of gateway or=
=0D
destination is rather void of meaning.=0D
=0D
-- =0D
R=C3=A9mi Denis-Courmont=0D
http://www.remlab.net=0D
http://fi.linkedin.com/in/remidenis

