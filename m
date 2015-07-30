From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [patch -master] netfilter: xt_CT: checking for IS_ERR() instead
 of NULL
Date: Thu, 30 Jul 2015 15:01:08 +0300
Message-ID: <20150730120108.GH5096@mwanda>
References: <20150727224228.GA10367@mwanda>
 <20150730115743.GA7077@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150730115743.GA7077@salvia>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 30, 2015 at 01:57:43PM +0200, Pablo Neira Ayuso wrote:
> I have also appended this chunk, since synproxy is also affected:

Thanks.  I have rechecked my scripts and I *should* have caught that.
I'm not sure what went wrong...

regards,
dan carpenter


