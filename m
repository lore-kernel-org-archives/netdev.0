From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2] tun: only queue packets on device
Date: Mon, 03 Dec 2012 14:48:59 -0500 (EST)
Message-ID: <20121203.144859.1267538781200082757.davem@davemloft.net>
References: <20121203194850.GA920@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jasowang@redhat.com, nhorman@tuxdriver.com, ramirose@gmail.com,
	davej@redhat.com, mtk.manpages@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: mst@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20121203194850.GA920@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Mon, 3 Dec 2012 21:48:50 +0200

>  
> +	/* This flag has no real effect.  We track the value for backwards
> +	 * compatibility. */

	/* Always
	 * like this.
	 */

	/*
	 * Never
	 * like this.
	 */

	 /* And never
	  * like this.  */
