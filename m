From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: Re: [PATCH v3 net-next 0/9] API set for HW Buffer management
Date: Sat, 05 Mar 2016 23:43:10 +0100
Message-ID: <87twkk5ywx.fsf@free-electrons.com>
References: <1457198221-21752-1-git-send-email-gregory.clement@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Jason Cooper <jason@lakedaemon.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	linux-arm-kernel@lists.infradead.org,
	Lior Amsalem <alior@marvell.com>,
	Nadav Haklai <nadavh@marvell.com>,
	Marcin Wojtas <mw@semihalf.com>,
	Simon Guinot <simon.guinot@sequanux.org>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	Willy Tarreau <w@1wt.eu>, Timor Kardashov <timork@marvell.com>,
	Sebastian Careba <nitroshift@yahoo.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from down.free-electrons.com ([37.187.137.238]:46852 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750851AbcCEWoD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Mar 2016 17:44:03 -0500
In-Reply-To: <1457198221-21752-1-git-send-email-gregory.clement@free-electrons.com>
	(Gregory CLEMENT's message of "Sat, 5 Mar 2016 18:16:52 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
 
 On sam., mars 05 2016, Gregory CLEMENT <gregory.clement@free-electrons.com> wrote:

> This is a third version of an API set for HW Buffer management that I

Please ignore this version.

Being able to select the HWBM support though the kernel configuration
was not as trivial as I initially thought. Fortunately, it was quickly
spotted by the 0-day kbuild bot, and I have just sent a new
version. Sorry for the noise.

Thanks,

Gregory

-- 
Gregory Clement, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
