From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: net: dsa: support switchdev FDB objects
Date: Tue, 4 Aug 2015 02:13:41 -0400 (EDT)
Message-ID: <960957436.2357.1438668821217.JavaMail.zimbra@savoirfairelinux.com>
References: <1438667683-18872-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	kernel <kernel@savoirfairelinux.com>,
	David <davem@davemloft.net>, Guenter Roeck <linux@roeck-us.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>
To: netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438667683-18872-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Aug 4, 2015, at 1:54 AM, Vivien Didelot vivien.didelot@savoirfairelinux.com wrote:

> This patchset refactors the DSA and mv88e6xxx code to use the switchdev FDB
> objects.
> 
> The first two patches add minor but necessary changes to switchdev, the third
> one implements the switchdev glue in DSA for FDB routines, and the forth one
> refactors the FDB access functions in the mv88e6xxx code.

For some reason the patch 4/4 didn't follow. I also missed the net-next
prefix, as mentioned by David earlier. Please ignore this serie, I will
retry soon.

Thanks,
-v
