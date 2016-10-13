From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v4 3/3] net: phy: leds: add support for led triggers on
 phy link state change
Date: Thu, 13 Oct 2016 18:40:30 +0200
Message-ID: <20161013164030.GB1286@lunn.ch>
References: <1476217580-21229-1-git-send-email-zach.brown@ni.com>
 <1476217580-21229-4-git-send-email-zach.brown@ni.com>
 <20161013.104634.2079376697690971907.davem@davemloft.net>
 <20161013154246.GA17387@zach-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, florian.c.schilhabel@googlemail.com,
 f.fainelli@gmail.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 j.anaszewski@samsung.com, rpurdie@rpsys.net, gregkh@linuxfoundation.org,
 Larry.Finger@lwfinger.net, David Miller <davem@davemloft.net>,
 linux-leds@vger.kernel.org, mlindner@marvell.com
To: Zach Brown <zach.brown@ni.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <20161013154246.GA17387@zach-desktop>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

> Do you have suggestions on how to better handle the choice of the array size
> and the speeds?

phydev->supported lists the speeds this phy supports.

	Andrew
