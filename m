From: Thomas Jarosch <thomas.jarosch@intra2net.com>
Subject: Re: TCP connection stalls under 2.6.24.7
Date: Thu, 31 Jul 2008 09:39:40 +0200
Message-ID: <200807310939.42406.thomas.jarosch@intra2net.com>
References: <47EA0DAB.7080205@securenet.de> <Pine.LNX.4.64.0807251613230.11302@wrl-59.cs.helsinki.fi> <200807251734.27743.thomas.jarosch@intra2net.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Ilpo =?iso-8859-15?q?J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>,
	Netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	Sven Riedel <sr@securenet.de>,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	David Miller <davem@davemloft.net>
To: "=?iso-8859-15?q?D=E2niel?= Fraga" <fragabr@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from re01.intra2net.com ([82.165.28.202]:43382 "EHLO
	re01.intra2net.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753593AbYGaHjr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2008 03:39:47 -0400
In-Reply-To: <200807251734.27743.thomas.jarosch@intra2net.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi D=E2niel,

On Thursday, 31. July 2008 06:47:38 you wrote:
> On Tue, 15 Jul 2008 15:30:45 -0300
>
> D=E2niel Fraga <fragabr@gmail.com> wrote:
> > 	I'm using kernel 2.6.26 and the problem has gone. No stalled
> > connections anymore. The problem was with 2.6.25 kernel only.
>
> 	Sorry, I was wrong. In 2.6.26 the problem remains.
>
> 	Everyday my connection stalls to my NNTP server using 2.6.26
> too. Before I just used a "nmap -sS server" and the connection would
> come back, but now it doesn't work.

Ok. Please try the latest patch Ilpo CC:ed you. Here's a link to the po=
st:
http://marc.info/?l=3Dlinux-netdev&m=3D121699478406378&w=3D2

Where is the NNTP server located? At your provider?

Thomas
