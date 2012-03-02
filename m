From: Alex Shi <alex.shi@intel.com>
Subject: Re: TCP_STREAM performance regression on commit b3613118
Date: Fri, 02 Mar 2012 14:37:57 +0800
Message-ID: <1330670277.21053.1448.camel@debian>
References: <1329472239.2861.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20120217.133327.1178765872497293871.davem@davemloft.net>
	 <1330656317.21053.1411.camel@debian>
	 <20120301.220743.2174015405223036036.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: feng.tang@intel.com, eric.dumazet@gmail.com,
	linux-kernel@vger.kernel.org, tim.c.chen@intel.com,
	ying.huang@intel.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120301.220743.2174015405223036036.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2012-03-01 at 22:07 -0500, David Miller wrote:
> From: Alex Shi <alex.shi@intel.com>
> Date: Fri, 02 Mar 2012 10:45:17 +0800
> 
> > Add CC to tang feng, He is working on this issue. 
> 
> Is he?  I'm pretty sure this is due to the TCP receive window growing
> issue Eric Dumazet, Neal Cardwell and I are discussing in the thread
> starting at:
> 
> http://marc.info/?l=linux-netdev&m=132916352815286&w=2

That's great! 
May my language make you confusing. Actually, Feng is doing
investigation on this issue. Since you fund out the reason, it saved his
work. :) 
