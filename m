From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: linux-next: build failure after merge of the final tree
 (net-current tree related)
Date: Mon, 25 Oct 2010 10:36:36 -0700
Message-ID: <20101025103636.442e108a@nehalam>
References: <20101025141956.d8f0888f.sfr@canb.auug.org.au>
	<20101024.222602.71095343.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	jchapman@katalix.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20101024.222602.71095343.davem@davemloft.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 24 Oct 2010 22:26:02 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Mon, 25 Oct 2010 14:19:56 +1100
> 
> > I wish doing that caused a build failure on other architectures ...
> 
> Me too :-/
> 
> > Subject: [PATCH] l2tp: static functions should not be exported
> 
> I'll add this thanks Stephen.

The section mismatch warning on x86 is not shown by default
because there are still so many problems.

-- 
