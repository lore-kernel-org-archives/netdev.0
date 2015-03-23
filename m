From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH 08/18] net: dsa: mv88e6xxx: Add Hardware bridging support
Date: Sun, 22 Mar 2015 18:33:15 -0700
Message-ID: <550F6D5B.6010505@roeck-us.net>
References: <1426952815-4642-1-git-send-email-linux@roeck-us.net> <1426952815-4642-9-git-send-email-linux@roeck-us.net> <20150322200600.GD15025@lunn.ch> <550F29FD.7050509@roeck-us.net> <20150322205957.GF15025@lunn.ch> <550F4498.9040203@roeck-us.net> <20150323011805.GG15025@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	linux-kernel@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150323011805.GG15025@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/22/2015 06:18 PM, Andrew Lunn wrote:
>> That also means that we'll have to move the list of switch IDs into
>> mv88e6xxx.h to be able to use it where needed (such as in mv88e6xxx_atu_cmd).
>
> I was thinking about doing that anyway. It would make it cleaner for
> handling statistics counters.
>

Makes sense. actually, I would say it is just cleaner, period.

Guenter
