From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC v3 3/3] phy,leds: add support for led triggers on phy link
 state change
Date: Tue, 11 Oct 2016 22:56:46 +0200
Message-ID: <20161011205646.GG14094@lunn.ch>
References: <1475874897-29720-1-git-send-email-zach.brown@ni.com>
 <1475874897-29720-4-git-send-email-zach.brown@ni.com>
 <1eb3afdb-0236-65e3-64be-09cc6eeda533@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Zach Brown <zach.brown@ni.com>, mlindner@marvell.com,
        stephen@networkplumber.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org,
        florian.c.schilhabel@googlemail.com, Larry.Finger@lwfinger.net,
        gregkh@linuxfoundation.org, rpurdie@rpsys.net,
        j.anaszewski@samsung.com, linux-leds@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1eb3afdb-0236-65e3-64be-09cc6eeda533@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Andrew, are you happy with this implementation?

Sorry, been to busy with other things to follow the discussion.

What would be nice to see is a comment about how the link to LEDs in
the PHYs is made. Often there is a couple of LEDs in the RJ45 socket
driven by the PHY. They can show link, speed, packet Rx/Tx, etc. How
are these triggers related to these LEDs?

    Andrew
