From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [patch v2] netfilter: nf_tables: underflow in
 nft_parse_u32_check()
Date: Mon, 17 Oct 2016 17:40:09 +0200
Message-ID: <20161017154009.GA15655@salvia>
References: <CAML_gOedjw6uJqp13YkGfXoLQTd_ikOC8OoUA4oXv15RYsgoUg@mail.gmail.com>
 <20161012091429.GA27317@mwanda>
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
In-Reply-To: <20161012091429.GA27317@mwanda>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 12, 2016 at 12:14:29PM +0300, Dan Carpenter wrote:
> We don't want to allow negatives here.

Applied, thanks.
