From: =?UTF-8?Q?R=C3=A9mi_Denis-Courmont?= <remi@remlab.net>
Subject: RE: looking for veth like.
Date: Fri, 15 Jan 2010 14:56:13 +0100
Message-ID: <012adedf9d99076f0b2428c7153a3f81@chewa.net>
References: <SNT109-W51E286B7253382E982C28F83690@phx.gbl>,
 <7df966df8e4352d5bad2da86990295a9@chewa.net> <SNT109-W45BBE115802D991CA1314283690@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: NetDev List <netdev@vger.kernel.org>
To: Christian Durieux <christian_durieux@hotmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:57549 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755612Ab0AON4P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Jan 2010 08:56:15 -0500
In-Reply-To: <SNT109-W45BBE115802D991CA1314283690@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Fri, 15 Jan 2010 13:30:28 +0000, Christian Durieux=0D
<christian_durieux@hotmail.com> wrote:=0D
>> Create two tap devices using /dev/net/tun and forward packets betwee=
n=0D
>> them.=0D
=0D
> I've been thinking of this but I need to stay at the kernel level (fo=
r=0D
> performance issue).=0D
=0D
Obviously, with an old kernel, you can't do something that requires a m=
ore=0D
recent kernel. Add two NICs and plug a cross cable between them if you=0D
don't want to involve user land.=0D
=0D
-- =0D
R=C3=A9mi Denis-Courmont=0D
http://www.remlab.net=0D
http://fi.linkedin.com/in/remidenis

