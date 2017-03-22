From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rhashtable: Add
	rhashtable_lookup_get_insert_fast
Date: Tue, 21 Mar 2017 17:52:56 -0700 (PDT)
Message-ID: <20170321.175256.1034761109998919012.davem@davemloft.net>
References: <1489793775-25152-1-git-send-email-agruenba@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, cluster-devel@redhat.com, tgraf@suug.ch
To: agruenba@redhat.com
Return-path: <cluster-devel-bounces@redhat.com>
In-Reply-To: <1489793775-25152-1-git-send-email-agruenba@redhat.com>
List-Unsubscribe: <https://www.redhat.com/mailman/options/cluster-devel>,
	<mailto:cluster-devel-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/cluster-devel>
List-Post: <mailto:cluster-devel@redhat.com>
List-Help: <mailto:cluster-devel-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/cluster-devel>,
	<mailto:cluster-devel-request@redhat.com?subject=subscribe>
Sender: cluster-devel-bounces@redhat.com
Errors-To: cluster-devel-bounces@redhat.com
List-Id: netdev.vger.kernel.org

From: Andreas Gruenbacher <agruenba@redhat.com>
Date: Sat, 18 Mar 2017 00:36:15 +0100

> Add rhashtable_lookup_get_insert_fast for fixed keys, similar to
> rhashtable_lookup_get_insert_key for explicit keys.
> 
> Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied to net-next, thanks.
