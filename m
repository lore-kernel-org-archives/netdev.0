From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: Re: [PATCH net-next 3/3] net: mvneta: Add naive RSS support
Date: Mon, 30 Nov 2015 17:40:05 +0100
Message-ID: <87poyr4f16.fsf@free-electrons.com>
References: <1448463243-21057-1-git-send-email-gregory.clement@free-electrons.com>
	<1448463243-21057-4-git-send-email-gregory.clement@free-electrons.com>
	<CAPv3WKfEJGAHgDvfyeHKZaiJqbsyrV+uKM+E3enbNLVznLY6zA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Jason Cooper <jason@lakedaemon.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	"linux-arm-kernel\@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	Lior Amsalem <alior@marvell.com>,
	Nadav Haklai <nadavh@marvell.com>,
	Simon Guinot <simon.guinot@sequanux.org>,
	Maxime Ripard <maxime.ripard@free-electrons.com>,
	Boris BREZILLON <boris.brezillon@free-electrons.com>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	Willy Tarreau <w@1wt.eu>
To: Marcin Wojtas <mw@semihalf.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAPv3WKfEJGAHgDvfyeHKZaiJqbsyrV+uKM+E3enbNLVznLY6zA@mail.gmail.com>
	(Marcin Wojtas's message of "Sat, 28 Nov 2015 17:43:57 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Marcin,
 
 On sam., nov. 28 2015, Marcin Wojtas <mw@semihalf.com> wrote:

> Hi Gregory,
>
>> +
>> +       /* update unicast mapping */
>> +       mvneta_set_rx_mode(pp->dev);
>
> I know it may be an ultimate level of nitpicking, but can you start a
> comment with capital letter?:)

If I got other review, then I can fix it in the next version. But if you
have a look on the otehr commet not all of them start by capital letter.

Thanks,

Greogry

>
> Best regards,
> Marcin

-- 
Gregory Clement, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
