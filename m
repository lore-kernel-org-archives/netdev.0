From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.38 containers bug: Infinite loop in
 /proc/sys/net/ipv6/neigh/neigh/neigh...
Date: Wed, 30 Mar 2011 03:35:29 -0700 (PDT)
Message-ID: <20110330.033529.71582712.davem@davemloft.net>
References: <4D92E9DC.3070405@parallels.com>
	<20110330.020120.02272125.davem@davemloft.net>
	<4D9302F3.6080206@parallels.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	containers@lists.linux-foundation.org, netdev@vger.kernel.org,
	stable@kernel.org
To: rlandley@parallels.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4D9302F3.6080206@parallels.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rob Landley <rlandley@parallels.com>
Date: Wed, 30 Mar 2011 05:16:19 -0500

> Pinging the stable guys to make sure this goes in a dot release.

Please do not do this.

I let fixes soak in Linus's tree for a week or even more before I submit
them to -stable.
