From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/3] sh_eth: E-DMAC interrupt mask cleanups
Date: Mon, 30 Jan 2017 11:18:16 -0500 (EST)
Message-ID: <20170130.111816.407600624117593483.davem@davemloft.net>
References: <3387005.NzsGXf10rT@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org
To: sergei.shtylyov@cogentembedded.com
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <3387005.NzsGXf10rT@wasted.cogentembedded.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Sun, 29 Jan 2017 15:06:39 +0300

>    Here's a set of 3 patches against DaveM's 'net-next.git' repo. The main goal
> of this set is to stop using the bare numbers for the E-DMAC interrupt masks.
> 
> [1/3] sh_eth: rename EESIPR bits
> [2/3] sh_eth: add missing EESIPR bits
> [3/3] sh_eth: stop using bare numbers for EESIPR values

Series applied, thank you.
