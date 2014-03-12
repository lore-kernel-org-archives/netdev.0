From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 9/9] ath9k: Convert uses of __constant_<foo>
 to <foo>
Date: Wed, 12 Mar 2014 15:29:24 -0400 (EDT)
Message-ID: <20140312.152924.644537848834821874.davem@davemloft.net>
References: <cover.1394644825.git.joe@perches.com>
	<b44fc68ea21f435c665dee1b2d1d89d6e53bd703.1394644825.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ath9k-devel@qca.qualcomm.com,
	linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	ath9k-devel@lists.ath9k.org, linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <b44fc68ea21f435c665dee1b2d1d89d6e53bd703.1394644825.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Wed, 12 Mar 2014 10:22:38 -0700

> The use of __constant_<foo> has been unnecessary for quite awhile now.
> 
> Make these uses consistent with the rest of the kernel.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Will let the wireless folks pick this up.
