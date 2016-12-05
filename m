From: David Miller <davem@davemloft.net>
Subject: Re: [patch net v2] net: fec: fix compile with CONFIG_M5272
Date: Mon, 05 Dec 2016 12:28:20 -0500 (EST)
Message-ID: <20161205.122820.1477248218044200770.davem@davemloft.net>
References: <51f44adf-486c-2e60-97c1-037d448fad49@cogentembedded.com>
        <20161205.121406.1568673407424770643.davem@davemloft.net>
        <90474527-926c-b66f-831b-3fb6f7128394@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lkp@intel.com, kbuild-all@01.org, fugang.duan@nxp.com,
        troy.kisky@boundarydevices.com, andrew@lunn.ch, eric@nelint.com,
        tremyfr@gmail.com, johannes@sipsolutions.net,
        netdev@vger.kernel.org, cphealy@gmail.com, fabio.estevam@nxp.com,
        linux-kernel@vger.kernel.org
To: nikita.yoush@cogentembedded.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <90474527-926c-b66f-831b-3fb6f7128394@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nikita Yushchenko <nikita.yoush@cogentembedded.com>
Date: Mon, 5 Dec 2016 20:26:52 +0300

>> From: Nikita Yushchenko <nikita.yoush@cogentembedded.com>
>> Date: Mon, 5 Dec 2016 16:55:04 +0300
>> 
>>> Aieee   I was typing too fast today, sorry...
>>>
>>> send separate "fix for the fix", or re-send patch without that silly typo?
>> 
>> If the patch hasn't been applied yet, you resend a fixed version of the
>> patch, always.
> 
> Ok, will repost shortly.
> 
> What I don't understand is - how could test robot fetch it before it was
> applied?

It takes them from the mailing list, and exactly this is the value of
the robot.  It can test patches before I add them to my tree.
