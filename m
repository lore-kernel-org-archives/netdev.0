From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [patch] netfilter: nft_exthdr: fix error handling in
 nft_exthdr_init()
Date: Mon, 17 Oct 2016 17:40:30 +0200
Message-ID: <20161017154030.GA15672@salvia>
References: <20161012060912.GF12841@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Laura Garcia Liebana <nevola@gmail.com>,
        Patrick McHardy <kaber@trash.net>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        "David S. Miller" <davem@davemloft.net>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161012060912.GF12841@mwanda>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 12, 2016 at 09:09:12AM +0300, Dan Carpenter wrote:
> "err" needs to be signed for the error handling to work.

Applied, thanks Dan.
