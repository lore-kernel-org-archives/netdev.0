From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: time for TCP ECN defaulting to on?
Date: Fri, 07 Nov 2008 10:12:20 +0100
Message-ID: <8763mzx5l7.fsf@obelix.mork.no>
References: <6278d2220811040632u7a36d68ekad5de517fd0671bb@mail.gmail.com>
	<alpine.DEB.1.10.0811052316210.10993@uplift.swm.pp.se>
	<20081105.151015.206163697.davem@davemloft.net>
	<alpine.DEB.1.10.0811070529550.10993@uplift.swm.pp.se>
	<Pine.LNX.4.64.0811070931190.23284@wrl-59.cs.helsinki.fi>
	<alpine.DEB.1.10.0811070854361.10993@uplift.swm.pp.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ilpo =?utf-8?Q?J=C3=A4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	David Miller <davem@davemloft.net>, daniel.blueman@gmail.com,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>, linux-net@vger.kernel.org
To: Mikael Abrahamsson <swmike@swm.pp.se>
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.1.10.0811070854361.10993@uplift.swm.pp.se> (Mikael
	Abrahamsson's message of "Fri, 7 Nov 2008 09:11:48 +0100 (CET)")
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mikael Abrahamsson <swmike@swm.pp.se> writes:

> I have sent an email (which will hopefully initiate a discussion) to =
a
> mailinglist populated by a lot of the operational ISP community and
> asked around about ECN and views on that. I also checked around on
> core router platforms (Cisco 12000 and Cisco CRS-1, which definitely
> is two of the top three core router platforms deployed in the world)
> and it seems they do not support ECN as far as I can discern.

I believe you can forget about ECN in core networks as long as these
searches fail:

 http://www.google.com/search?q=3D%22rfc+5129%22+site%3Acisco.com
 http://www.google.com/search?q=3D%22rfc+5129%22+site%3Ajuniper.net



Bj=C3=B8rn
