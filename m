From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [Bug 3440] New: eth0 freezes: "NETDEV WATCHDOG: eth0: transmit timed out "
Date: Wed, 22 Sep 2004 22:22:27 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040922202227.GA23275@electric-eye.fr.zoreil.com>
References: <20040922092713.18711d2d@dell_ss3.pdx.osdl.net> <BJEDLIFMBCLIGJJBNCLJGECPCPAA.per.sil@gmx.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>, john.ronciak@intel.com,
        ganesh.venkatesan@intel.com, scott.feldman@intel.com,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Perolo Silantico <per.sil@gmx.it>
Content-Disposition: inline
In-Reply-To: <BJEDLIFMBCLIGJJBNCLJGECPCPAA.per.sil@gmx.it>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Perolo Silantico <per.sil@gmx.it> :
> Same behaviour for drivers:
>   - 8139too (kernel 2.6.8.1 and 2.6.8)
>   - e100 (kernel 2.6.8)
>   - eepro100 (kernel 2.6.8.1)
> 
> I have tried with all these drivers. Therefore it seemed to me, that
> this is not related to any specific driver. But to be sure, I will
> grab a 3com 905C from another server and try with that one and will
> try with the PCNet32 too.

Can you give a try to 2.6.7 for the 8139 setup ?

A dmesg from a working 2.4.x may help figure some difference.

--
Ueimor
