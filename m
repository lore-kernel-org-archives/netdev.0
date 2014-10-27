From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH v2 09/15] net: dsa: Add support for switch EEPROM access
Date: Mon, 27 Oct 2014 09:50:48 +0100
Message-ID: <20141027085048.GC4748@netboy>
References: <1414342365-27191-1-git-send-email-linux@roeck-us.net>
 <1414342365-27191-10-git-send-email-linux@roeck-us.net>
 <20141027024121.GA16998@lunn.ch>
 <544DC264.9020600@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Lunn <andrew@lunn.ch>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	linux-kernel@vger.kernel.org
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <544DC264.9020600@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Oct 26, 2014 at 08:56:20PM -0700, Guenter Roeck wrote:
> 
> Also, it seems that you request two separate properties, one for presence
> and another for length. Is that correct ? Again, I thought that would not
> provide any value since presence is indicated by length != 0 in the ethtool
> callback function. No problem, though, I'll be happy to create two separate
> properties and platform data variables if you think that would be better.

The fewer properties, the better.

Thanks,
Richard
