From: Marcin Wojtas <mw@semihalf.com>
Subject: Re: [PATCH net-next 3/3] net: mvneta: Add naive RSS support
Date: Sat, 28 Nov 2015 17:43:57 +0100
Message-ID: <CAPv3WKfEJGAHgDvfyeHKZaiJqbsyrV+uKM+E3enbNLVznLY6zA@mail.gmail.com>
References: <1448463243-21057-1-git-send-email-gregory.clement@free-electrons.com>
	<1448463243-21057-4-git-send-email-gregory.clement@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Jason Cooper <jason@lakedaemon.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	Lior Amsalem <alior@marvell.com>,
	Nadav Haklai <nadavh@marvell.com>,
	Simon Guinot <simon.guinot@sequanux.org>,
	Maxime Ripard <maxime.ripard@free-electrons.com>,
	Boris BREZILLON <boris.brezillon@free-electrons.com>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	Willy Tarreau <w@1wt.eu>
To: Gregory CLEMENT <gregory.clement@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1448463243-21057-4-git-send-email-gregory.clement@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Gregory,

> +
> +       /* update unicast mapping */
> +       mvneta_set_rx_mode(pp->dev);

I know it may be an ultimate level of nitpicking, but can you start a
comment with capital letter?:)

Best regards,
Marcin
