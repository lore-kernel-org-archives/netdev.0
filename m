From: Mirko Lindner <demon@pro-linux.de>
Subject: Re: [PATCH]sk98lin ethtool support
Date: Wed, 31 Dec 2003 01:15:31 +0000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FF22333.2070004@pro-linux.de>
References: <1072779867.3632.38.camel@l5ac210.l5.laser5.co.jp> <3FF16F18.7060303@pro-linux.de> <3FF19659.8030408@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: krishnakumar@naturesoft.net, mlindner@syskonnect.de, netdev@oss.sgi.com,
        felix@allot.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <3FF19659.8030408@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Mirko Lindner wrote:
> 
>> Thanks. I'll complete the support as soon I'm back in the office. All 
>> driver statistics are also available in the the proc system under 
>> /proc/net/sk98lin/
> 
> 
> 
> procfs statistics are deprecated...
> 
>     Jeff

Jeff,

the proc statistics are integrated in the driver since kernel 2.2. I'll 
include full support for ethtool as soon I've time to do this. At the 
moment I'm still working on a support for the upcoming Marvell chipset 
(it would be great to support Linux as soon the chip is availiable) and 
a Diag-Tool for all Genesis and Yukon based cards (GUI and console tool).


Mirko
