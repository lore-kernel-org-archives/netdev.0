From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] phy: micrel: fix issues with interrupt on atmel
 boards
Date: Tue, 01 Mar 2016 16:53:26 -0500 (EST)
Message-ID: <20160301.165326.2279799824419089467.davem@davemloft.net>
References: <1456510703-31559-1-git-send-email-alexandre.belloni@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, nicolas.ferre@atmel.com, andrew@lunn.ch,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: alexandre.belloni@free-electrons.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1456510703-31559-1-git-send-email-alexandre.belloni@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexandre Belloni <alexandre.belloni@free-electrons.com>
Date: Fri, 26 Feb 2016 19:18:21 +0100

> Since the phy is not polled anymore, there were issues getting a link on the
> sama5d* xplained boards.
 ...

Series applied, thanks.
