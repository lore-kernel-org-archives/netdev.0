From: "Catalin(ux aka Dino) BOIE" <util@deuroconsult.ro>
Subject: Re: Why /sys/class/net/*/features is read-only?
Date: Tue, 24 May 2005 00:53:58 +0300 (EEST)
Message-ID: <Pine.LNX.4.62.0505240052300.17855@webhosting.rdsbv.ro>
References: <Pine.LNX.4.62.0505232346310.17855@webhosting.rdsbv.ro>
 <20050523.135348.55831423.davem@davemloft.net>
 <Pine.LNX.4.62.0505240032480.17855@webhosting.rdsbv.ro>
 <20050523.145112.78711028.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050523.145112.78711028.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 23 May 2005, David S. Miller wrote:

> From: "Catalin(ux aka Dino) BOIE" <util@deuroconsult.ro>
> Date: Tue, 24 May 2005 00:33:14 +0300 (EEST)
>
>> On Mon, 23 May 2005, David S. Miller wrote:
>>
>>> Let them use ethtool :-)
>>
>> They can't on a bridge device, right?
>
> Currently no.  But there is no reason the bridge device
> should not have ethtool support added to it, and that's
> where this functionality belongs.

OK. I made this patch only to test how well slave notification worked.
Next days I will implement ethtool for bridge.

Thank you!
---
Catalin(ux aka Dino) BOIE
catab at deuroconsult.ro
http://kernel.umbrella.ro/
