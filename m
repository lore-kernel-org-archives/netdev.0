From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 06/14] net: dsa: Add support for hardware monitoring
Date: Sat, 25 Oct 2014 10:26:06 -0700
Message-ID: <544BDD2E.6010604@gmail.com>
References: <CAGVrzcYjPJWai9bxkh+WRrEEAzBKBd-LQm7zDeeouxngr_v9SQ@mail.gmail.com> <54488CE1.2000106@roeck-us.net> <20141023134706.GB25190@lunn.ch> <20141023162754.GA21343@roeck-us.net> <20141023165459.GE25190@lunn.ch> <20141023173847.GA22988@roeck-us.net> <20141023180357.GG25190@lunn.ch> <20141023184322.GA24281@roeck-us.net> <20141023195526.GH25190@lunn.ch> <20141024161919.GA29600@roeck-us.net> <20141025140116.GA12051@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>, Guenter Roeck <linux@roeck-us.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141025140116.GA12051@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/25/14 07:01, Andrew Lunn wrote:
>> Here is another naming option:
>>
>> em1dsa0-virtual-0
> 
> I prefer this over isa.
> 
> However, i think there should be some sort of separator between the
> network device name and dsa.

Considering that network devices can be renamed, do we want it to be
included in the sensor name at all?
--
Florian
