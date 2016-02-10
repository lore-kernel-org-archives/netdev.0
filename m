From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/2] Factor out register bit twiddling in the
 Renesas Ethernet drivers
Date: Wed, 10 Feb 2016 05:38:49 -0500 (EST)
Message-ID: <20160210.053849.491932166273511451.davem@davemloft.net>
References: <2107757.v1oGBJ7aiG@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org
To: sergei.shtylyov@cogentembedded.com
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <2107757.v1oGBJ7aiG@wasted.cogentembedded.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Wed, 10 Feb 2016 01:36:55 +0300

>    Here's a set of 2 patches against DaveM's 'net-next.git' repo. We factor out
> the often repeated pattern of reading a register, AND'ing and/or OR'ing some
> bits, and then writing the value back.
> 
> [1/2] ravb: factor out register bit twiddling code
> [2/2] sh_eth: factor out register bit twiddling code

Series applied, thanks.
