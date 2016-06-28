From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] etherdevice.h & bridge: netfilter: Add and use
 ether_addr_equal_masked
Date: Tue, 28 Jun 2016 09:01:12 -0400 (EDT)
Message-ID: <20160628.090112.1438085992622018555.davem@davemloft.net>
References: <20160624085752.GB1939@salvia>
	<3dcddfef3b9ac0eceb2869d9e95ae857b509fabe.1466793022.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, coreteam@netfilter.org,
	netfilter-devel@vger.kernel.org, kadlec@blackhole.kfki.hu,
	kaber@trash.net, pablo@netfilter.org
To: joe@perches.com
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <3dcddfef3b9ac0eceb2869d9e95ae857b509fabe.1466793022.git.joe@perches.com>
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

From: Joe Perches <joe@perches.com>
Date: Fri, 24 Jun 2016 11:32:26 -0700

> There are code duplications of a masked ethernet address comparison here
> so make it a separate function instead.
> 
> Miscellanea:
> 
> o Neaten alignment of FWINV macro uses to make it clearer for the reader
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Pablo feel free to take this:

Acked-by: David S. Miller <davem@davemloft.net>
