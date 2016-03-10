From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] sh_eth: fix couple of bugs in sh_eth_ring_format()
Date: Thu, 10 Mar 2016 16:07:52 -0500 (EST)
Message-ID: <20160310.160752.440578142471376021.davem@davemloft.net>
References: <4881302.XJJSmqvE1J@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org
To: sergei.shtylyov@cogentembedded.com
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <4881302.XJJSmqvE1J@wasted.cogentembedded.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Tue, 08 Mar 2016 01:33:38 +0300

>    Here's a set of 2 patches against DaveM's 'net.git' repo fixing two bugs
> in sh_eth_.ring_format()...
> 
> [1/2] sh_eth: fix NULL pointer dereference in sh_eth_ring_format()
> [2/2] sh_eth: advance 'rxdesc' later in sh_eth_ring_format()

Since Linus is likely to release today or otherwise very soon I'm not
putting things into 'net'.

So I've applied this series to 'net-next', let me know if I should
queue it up for stable.

Thanks.
