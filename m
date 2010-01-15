From: =?UTF-8?Q?R=C3=A9mi_Denis-Courmont?= <remi@remlab.net>
Subject: Re: looking for veth like.
Date: Fri, 15 Jan 2010 13:29:33 +0100
Message-ID: <7df966df8e4352d5bad2da86990295a9@chewa.net>
References: <SNT109-W51E286B7253382E982C28F83690@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Christian Durieux <christian_durieux@hotmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:51895 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757091Ab0AOM3e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Jan 2010 07:29:34 -0500
In-Reply-To: <SNT109-W51E286B7253382E982C28F83690@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Fri, 15 Jan 2010 11:55:03 +0000, Christian Durieux=0D
<christian_durieux@hotmail.com> wrote:=0D
> Is there a way to=C2=A0 do the same with that oldest kernel release ?=
=0D
> It there an veth-like module ? (I saw some stuffs suche as etun but c=
an=0D
> not get it... ?)=0D
=0D
Create two tap devices using /dev/net/tun and forward packets between t=
hem.=0D
=0D
-- =0D
R=C3=A9mi Denis-Courmont=0D
http://www.remlab.net=0D
http://fi.linkedin.com/in/remidenis

