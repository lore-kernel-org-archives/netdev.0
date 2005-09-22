From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 0/3] netfilter : 3 patches to boost ip_tables performance
Date: Wed, 21 Sep 2005 17:34:08 -0700 (PDT)
Message-ID: <20050921.173408.122945960.davem@davemloft.net>
References: <43308324.70403@cosmosbay.com> <4331CFA7.50104@cosmosbay.com>
	<Pine.LNX.4.62.0509211542210.13045@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ak@suse.de, netfilter-devel@lists.netfilter.org,
	linux-kernel@vger.kernel.org, dada1@cosmosbay.com
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: clameter@engr.sgi.com
In-Reply-To: <Pine.LNX.4.62.0509211542210.13045@schroedinger.engr.sgi.com>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

From: Christoph Lameter <clameter@engr.sgi.com>
Date: Wed, 21 Sep 2005 15:43:29 -0700 (PDT)

> Maybe we better introduce vmalloc_node() instead of improvising this for 
> several subsystems? The e1000 driver has similar issues.

I agree.
