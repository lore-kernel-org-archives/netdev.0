From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net-next] netfilter: xt_socket: use IP early demux
Date: Thu, 23 May 2013 12:53:44 +0200
Message-ID: <20130523105344.GA22507@localhost>
References: <1369256466.3301.364.camel@edumazet-glaptop>
 <20130522.142733.458456664835859037.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130522.142733.458456664835859037.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 22, 2013 at 02:27:33PM -0700, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 22 May 2013 14:01:06 -0700
> 
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > With IP early demux added in linux-3.6, we perform TCP lookup in IP
> > layer before iptables hooks.
> > 
> > We can avoid doing a second lookup in xt_socket.
> > 
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> 
> Acked-by: David S. Miller <davem@davemloft.net>

Applied to nf-next, thanks!
