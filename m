From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] etherdevice.h & bridge: netfilter: Add and use
 ether_addr_equal_masked
Date: Thu, 30 Jun 2016 11:26:50 +0200
Message-ID: <20160630092650.GA2107@salvia>
References: <20160624085752.GB1939@salvia>
	<3dcddfef3b9ac0eceb2869d9e95ae857b509fabe.1466793022.git.joe@perches.com>
	<20160628.090112.1438085992622018555.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, coreteam@netfilter.org,
	netfilter-devel@vger.kernel.org, kadlec@blackhole.kfki.hu,
	joe@perches.com, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <bridge-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20160628.090112.1438085992622018555.davem@davemloft.net>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 28, 2016 at 09:01:12AM -0400, David Miller wrote:
> From: Joe Perches <joe@perches.com>
> Date: Fri, 24 Jun 2016 11:32:26 -0700
> 
> > There are code duplications of a masked ethernet address comparison here
> > so make it a separate function instead.
> > 
> > Miscellanea:
> > 
> > o Neaten alignment of FWINV macro uses to make it clearer for the reader
> > 
> > Signed-off-by: Joe Perches <joe@perches.com>
> 
> Pablo feel free to take this:
> 
> Acked-by: David S. Miller <davem@davemloft.net>

Applied, thanks!
