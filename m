From: Eric Wong <normalperson@yhbt.net>
Subject: Re: splice() giving unexpected EOF in 3.7.3 and 3.8-rc4+
Date: Fri, 8 Feb 2013 02:39:46 +0000
Message-ID: <20130208023946.GA23197@dcvr.yhbt.net>
References: <20130119044957.GA25395@dcvr.yhbt.net>
 <1358574847.3464.422.camel@edumazet-glaptop>
 <1358575996.3464.447.camel@edumazet-glaptop>
 <20130120.232122.1798689273842981732.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org, w@1wt.eu
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130120.232122.1798689273842981732.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Fri, 18 Jan 2013 22:13:16 -0800
> 
> > On Fri, 2013-01-18 at 21:54 -0800, Eric Dumazet wrote:
> > 
> >> 
> >> Hmm, this might be already fixed in net-next tree, could you try it ?
> >> 
> > 
> > Yes, running your program on net-next seems OK.
> > 
> > David, we need the two following commits.
> 
> Tossed into 'net' and queued up for -stable, thanks.

Hi David, any update on getting these into -stable?  Thanks.
