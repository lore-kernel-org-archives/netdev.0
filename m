From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [netdrvr] netdev-2.6 queue updated
Date: Mon, 15 Nov 2004 12:09:47 -0500
Message-ID: <4198E2DB.5010800@pobox.com>
References: <3ACA40606221794F80A5670F0AF15F8403BD583B@pdsmsx403>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org, akpm@osdl.org,
        Jouni Malinen <jkmaline@cc.hut.fi>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Zhu, Yi" <yi.zhu@intel.com>
In-Reply-To: <3ACA40606221794F80A5670F0AF15F8403BD583B@pdsmsx403>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Zhu, Yi wrote:
> Jeff Garzik wrote:
> 
>>The most notable thing is the addition of HostAP.
> 
> 
> How about move HostAP 802.11 stack and crypt related files to
> net/80211? It is generic and some other drivers (i.e. ipw2100) share
> the code. Do you receive patches to do this?


Jouni mentioned he wanted to do a few things before we started renaming?

I would like someone at Intel to submit the ipw drivers, and start 
working on them via the wireless-2.6 tree eventually[1]

	Jeff


[1] once we have permission to put the firmware in the kernel
