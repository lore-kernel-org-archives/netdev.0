From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/13] net: Add and use ether_addr_equal
Date: Wed, 09 May 2012 21:53:30 -0400 (EDT)
Message-ID: <20120509.215330.1797609915710094377.davem@davemloft.net>
References: <cover.1336538937.git.joe@perches.com>
	<20120509.212110.437114897180819434.davem@davemloft.net>
	<1336614484.1905.19.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: coreteam@netfilter.org, linux-bluetooth@vger.kernel.org,
	netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
	julia.lawall@lip6.fr, netfilter@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: joe@perches.com
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1336614484.1905.19.camel@joe2Laptop>
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
Date: Wed, 09 May 2012 18:48:04 -0700

> Maybe just a single patch?

Yes, I think high density on this one, it's extremely
mechanical.

> Also the compare_ether_addr_64bits function is
> still used a couple dozen times.  Maybe another
> patch for those?  ether_addr_equal_64bits?

Use your best judgment.
