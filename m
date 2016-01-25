From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 26/26] tcp: Use ahash
Date: Sun, 24 Jan 2016 22:01:47 -0800 (PST)
Message-ID: <20160124.220147.1840338377819463012.davem@davemloft.net>
References: <20160124131021.GA31153@gondor.apana.org.au>
	<E1aNKad-0008H5-Ax@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-crypto@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, devel@driverdev.osuosl.org,
	dm-devel@redhat.com, linux-wireless@vger.kernel.org,
	linux-cifs@vger.kernel.org, ecryptfs@vger.kernel.org,
	linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net,
	linux-nfs@vger.kernel.org, keyrings@vger.kernel.org,
	linux-bluetooth@vger.kernel.org, ceph-devel@vger.kernel.org,
	linux-wpan@vger.kernel.org, linux-afs@lists.infradead.org,
	drbd-dev@lists.linbit.com, open-iscsi@googlegroups.com
To: herbert@gondor.apana.org.au
Return-path: <ecryptfs-owner@vger.kernel.org>
In-Reply-To: <E1aNKad-0008H5-Ax@gondolin.me.apana.org.au>
Sender: ecryptfs-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 24 Jan 2016 21:20:23 +0800

> This patch replaces uses of the long obsolete hash interface with
> ahash.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Acked-by: David S. Miller <davem@davemloft.net>
