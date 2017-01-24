From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: Re: [PATCH v5 0/2] Add support for the ethernet switch on the ESPRESSObin
Date: Tue, 24 Jan 2017 17:47:06 +0100
Message-ID: <87r33s2ynp.fsf@free-electrons.com>
References: <20170119214934.27442-1-gregory.clement@free-electrons.com>
        <20170120.141705.1390880809796992457.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: andrew@lunn.ch, f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, jason@lakedaemon.net,
        sebastian.hesselbarth@gmail.com,
        thomas.petazzoni@free-electrons.com,
        linux-arm-kernel@lists.infradead.org, nadavh@marvell.com,
        dingwei@marvell.com, kostap@marvell.com, shjzhou@marvell.com,
        jpannell@marvell.com
To: David Miller <davem@davemloft.net>,
        vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170120.141705.1390880809796992457.davem@davemloft.net> (David
        Miller's message of "Fri, 20 Jan 2017 14:17:05 -0500 (EST)")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,
 
 On ven., janv. 20 2017, David Miller <davem@davemloft.net> wrote:

> From: Gregory CLEMENT <gregory.clement@free-electrons.com>
> Date: Thu, 19 Jan 2017 22:49:32 +0100
>
>> I created a new family for this switch and filled the ops structure
>> by selecting which seems the more appropriate functions. I rebased
>> the series on net-next/master which allowed me to benefit to the
>> eeprom functions introduced for the 6390.
>
> It looks like there will be at least one more respin of this series,
> specifically to remove the new family as Vivien seems to object to
> this.

I am about to send a new version. However about removing the new family,
I thought that with the confirmation from Andrew we could keep it.

Vivien could you confirm this?

Thanks,

Gregory

-- 
Gregory Clement, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
