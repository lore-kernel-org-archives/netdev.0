From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH 15/26] Bluetooth: Use skcipher and hash
Date: Mon, 25 Jan 2016 07:48:46 +0100
Message-ID: <B35B9E9E-DA6B-4AAD-B1EF-2DE778645CAC@holtmann.org>
References: <20160124131021.GA31153@gondor.apana.org.au> <E1aNKYo-0008Dp-5h@gondolin.me.apana.org.au>
Mime-Version: 1.0 (Mac OS X Mail 9.2 \(3112\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	devel@driverdev.osuosl.org, dm-devel@redhat.com,
	linux-wireless <linux-wireless@vger.kernel.org>,
	linux-cifs@vger.kernel.org, ecryptfs@vger.kernel.org,
	linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net,
	linux-nfs@vger.kernel.org, keyrings@vger.kernel.org,
	BlueZ development <linux-bluetooth@vger.kernel.org>,
	ceph-devel@vger.kernel.org, linux-wpan@vger.kernel.org,
	linux-afs@lists.infradead.org, drbd-dev@lists.linbit.com,
	open-iscsi@googlegroups.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <ecryptfs-owner@vger.kernel.org>
In-Reply-To: <E1aNKYo-0008Dp-5h@gondolin.me.apana.org.au>
Sender: ecryptfs-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Herbert,

> This patch replaces uses of blkcipher with skcipher and the long
> obsolete hash interface with shash.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Acked-by: Marcel Holtmann <marcel@holtmann.org>

> ---
> 
> net/bluetooth/smp.c |  135 ++++++++++++++++++++++++----------------------------
> 1 file changed, 63 insertions(+), 72 deletions(-)

Regards

Marcel
