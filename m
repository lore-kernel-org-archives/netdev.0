From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: TCP connection stalls under 2.6.24.7
Date: Fri, 8 Aug 2008 13:32:30 +0300
Message-ID: <200808081332.31284.denys@visp.net.lb>
References: <47EA0DAB.7080205@securenet.de> <200808071523.04586.denys@visp.net.lb> <Pine.LNX.4.64.0808081005440.4378@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "=?iso-8859-1?q?D=E2niel?= Fraga" <fragabr@gmail.com>,
	Thomas Jarosch <thomas.jarosch@intra2net.com>,
	Netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	Sven Riedel <sr@securenet.de>,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	David Miller <davem@davemloft.net>
To: "Ilpo =?iso-8859-1?q?J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:49329 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753548AbYHHKdW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Aug 2008 06:33:22 -0400
In-Reply-To: <Pine.LNX.4.64.0808081005440.4378@wrl-59.cs.helsinki.fi>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 08 August 2008, Ilpo J=E4rvinen wrote:

> I thought it was "trivial to reproduce"... :-) Perhaps it was then ju=
st
> related to pre-2.6.25.7 kernels?
Trivial to reproduce, but it is production systems with 600-700 req/s, =
i=20
cannot take much risk with them, and it semi-embedded distro running on=
 USB=20
flash.
I am just trying now to use them, if i will have failures, i will buy P=
C and=20
build something on my table.
