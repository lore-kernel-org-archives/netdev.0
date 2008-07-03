From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] tun: Allow GSO using virtio_net_hdr
Date: Thu, 03 Jul 2008 03:48:13 -0700 (PDT)
Message-ID: <20080703.034813.210177394.davem@davemloft.net>
References: <200807031132.12810.rusty@rustcorp.com.au>
	<200807031133.11813.rusty@rustcorp.com.au>
	<200807031134.15036.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: markmc@redhat.com, netdev@vger.kernel.org, maxk@qualcomm.com,
        virtualization@lists.linux-foundation.org
To: rusty@rustcorp.com.au
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <200807031134.15036.rusty@rustcorp.com.au>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/virtualization>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

From: Rusty Russell <rusty@rustcorp.com.au>
Date: Thu, 3 Jul 2008 11:34:14 +1000

> Add a IFF_VNET_HDR flag.  This uses the same ABI as virtio_net (ie. prepending
> struct virtio_net_hdr to packets) to indicate GSO and checksum information.
> 
> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>

Also applied to net-next-2.6
