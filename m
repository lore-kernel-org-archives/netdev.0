From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [TCP]: =?UTF-8?Q?min=5Ft/max=5Ft=20confusion=20in=20tcp=5Fsel?=  =?UTF-8?Q?ect=5Finitial=5Fwindow=28=29=3F?=
Date: Wed, 18 Aug 2010 16:09:30 +0200
Message-ID: <93bf5f79c0e69b1853298bbce1876b5b@localhost>
References: <4B3179B8.5000403@gmail.com>
 <20091222.194747.193724694.davem@davemloft.net>
 <alpine.DEB.2.00.0912232140500.10866@melkinpaasi.cs.helsinki.fi>
 <20091223.131526.193724825.davem@davemloft.net>
 <alpine.DEB.2.00.0912232321090.10866@melkinpaasi.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, <roel.kluin@gmail.com>,
	Netdev <netdev@vger.kernel.org>
To: =?UTF-8?Q?Ilpo_J=C3=A4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:34142 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753190Ab0HROJs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Aug 2010 10:09:48 -0400
In-Reply-To: <alpine.DEB.2.00.0912232321090.10866@melkinpaasi.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 23 Dec 2009 23:23:11 +0200 (EET), "Ilpo J=C3=A4rvinen" wrote:=0D
=0D
> Yeah, I'm wrong, and besides misread your "It looks correct" to mean =
the=0D
=0D
> proposed change rather than the current code.=0D
=0D
But the code is not correct if we consider reduced buffers via=0D
setsockopt(), some days ago I sent a patch to fix the problem.=0D
=0D
Ilpo? David?=0D
=0D
Hagen=0D

