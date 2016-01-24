From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/26] block: cryptoloop - Use new skcipher interface
Date: Sun, 24 Jan 2016 21:39:39 +0800
Message-ID: <20160124133939.GA32106@gondor.apana.org.au>
References: <E1aNKWU-0008A9-Dx@gondolin.me.apana.org.au>
 <201601242148.Yk7531Nh%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org,
	Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, devel@driverdev.osuosl.org,
	dm-devel@redhat.com, linux-wireless@vger.kernel.org,
	linux-cifs@vger.kernel.org, ecryptfs@vger.kernel.org,
	linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net,
	linux-nfs@vger.kernel.org, keyrings@vger.kernel.org,
	linux-bluetooth@vger.kernel.org, ceph-devel@vger.kernel.org,
	linux-wpan@vger.kernel.org, linux-afs@lists.infradead.org,
	drbd-dev@lists.linbit.com, open-iscsi@googlegroups.com
To: kbuild test robot <lkp@intel.com>
Return-path: <ceph-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201601242148.Yk7531Nh%fengguang.wu@intel.com>
Sender: ceph-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jan 24, 2016 at 09:37:33PM +0800, kbuild test robot wrote:
> 
> [auto build test ERROR on net/master]
> [also build test ERROR on v4.4 next-20160122]
> [if your patch is applied to the wrong git tree, please drop us a note to help improving the system]

These patches depend on the two helpers that I posted yesterday
so unfortunately we'll be getting quite a few build errors from
the bot.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
