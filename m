From: John Crispin <john@phrozen.org>
Subject: Re: [PATCH] net: dsa: add FIB support
Date: Mon, 12 Sep 2016 20:34:46 +0200
Message-ID: <ce71b5f0-d153-57ee-0db6-37b7ec2d236b@phrozen.org>
References: <1473675233-36952-1-git-send-email-john@phrozen.org>
 <20160912140002.GH11400@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160912140002.GH11400@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 12/09/2016 16:00, Andrew Lunn wrote:
> Hi John
> 
>> +	if (!ds->drv->ipv4_fib_prepare || !ds->drv->ipv4_fib_add)
> 
> drv recently got renamed to ops, which is what 0-day is complaining
> about.
> 
> 	Andrew
> 

i based this on a net-next from 5-6 days ago, will rebase/resend tomorrow.

	John
