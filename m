From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/9] brocade: Convert uses of __constant_<foo>
 to <foo>
Date: Wed, 12 Mar 2014 15:30:20 -0400 (EDT)
Message-ID: <20140312.153020.56358162987437159.davem@davemloft.net>
References: <cover.1394644825.git.joe@perches.com>
	<784c96cedcbfc68e05a8814fc8acfb3f142639d9.1394644825.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rmody@brocade.com,
	linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <784c96cedcbfc68e05a8814fc8acfb3f142639d9.1394644825.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Wed, 12 Mar 2014 10:22:30 -0700

> The use of __constant_<foo> has been unnecessary for quite awhile now.
> 
> Make these uses consistent with the rest of the kernel.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied.
