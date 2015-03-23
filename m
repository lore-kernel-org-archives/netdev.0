From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 08/18] net: dsa: mv88e6xxx: Add Hardware bridging support
Date: Mon, 23 Mar 2015 02:18:05 +0100
Message-ID: <20150323011805.GG15025@lunn.ch>
References: <1426952815-4642-1-git-send-email-linux@roeck-us.net>
 <1426952815-4642-9-git-send-email-linux@roeck-us.net>
 <20150322200600.GD15025@lunn.ch>
 <550F29FD.7050509@roeck-us.net>
 <20150322205957.GF15025@lunn.ch>
 <550F4498.9040203@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	linux-kernel@vger.kernel.org
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <550F4498.9040203@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> That also means that we'll have to move the list of switch IDs into
> mv88e6xxx.h to be able to use it where needed (such as in mv88e6xxx_atu_cmd).

I was thinking about doing that anyway. It would make it cleaner for
handling statistics counters.

	 Andrew
