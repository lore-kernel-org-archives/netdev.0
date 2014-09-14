From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Subject: Re: [PATCH net-next 5/5] netfilter: Convert pr_warning to pr_warn
Date: Sun, 14 Sep 2014 21:13:41 +0200 (CEST)
Message-ID: <alpine.DEB.2.10.1409142112320.1020@blackhole.kfki.hu>
References: <cover.1410322181.git.joe@perches.com> <4708b4ef0485c1bc9efe3c0e59924a0f1c3c3bb4.1410322181.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4708b4ef0485c1bc9efe3c0e59924a0f1c3c3bb4.1410322181.git.joe@perches.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 9 Sep 2014, Joe Perches wrote:

> Use the more common pr_warn.
> 
> Other miscellanea:
> 
> o Coalesce formats
> o Realign arguments
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
>  net/netfilter/ipset/ip_set_core.c     | 23 +++++++++++-----------
>  net/netfilter/ipset/ip_set_hash_gen.h | 12 ++++++------
>  net/netfilter/xt_connbytes.c          |  2 +-
>  net/netfilter/xt_hashlimit.c          |  2 +-
>  net/netfilter/xt_set.c                | 36 ++++++++++++++++-------------------
>  5 files changed, 35 insertions(+), 40 deletions(-)

Acked-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

Best regards,
Jozsef
-
E-mail  : kadlec@blackhole.kfki.hu, kadlecsik.jozsef@wigner.mta.hu
PGP key : http://www.kfki.hu/~kadlec/pgp_public_key.txt
Address : Wigner Research Centre for Physics, Hungarian Academy of Sciences
          H-1525 Budapest 114, POB. 49, Hungary
