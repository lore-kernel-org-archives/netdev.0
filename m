From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH v3] netfilter: ipset: Fix sleeping memory allocation in
 atomic context
Date: Sat, 17 Oct 2015 12:59:30 +0200
Message-ID: <20151017105930.GA1527@salvia>
References: <1444977628-19323-1-git-send-email-kernel@kyup.com>
 <alpine.DEB.2.10.1510161357380.15639@blackhole.kfki.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nikolay Borisov <kernel@kyup.com>, eric.dumazet@gmail.com,
	netfilter-devel@vger.kernel.org,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	operations@siteground.com
To: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1510161357380.15639@blackhole.kfki.hu>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 16, 2015 at 01:58:55PM +0200, Jozsef Kadlecsik wrote:
> The patch is applied in the ipset package tree. Thanks!

Applied to the nf tree, thanks.
