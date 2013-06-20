From: David Miller <davem@davemloft.net>
Subject: Re: [Trivial PATCH 28/33] ipv6: Convert use of typedef ctl_table
 to struct ctl_table
Date: Wed, 19 Jun 2013 23:18:28 -0700 (PDT)
Message-ID: <20130619.231828.475359282144437191.davem@davemloft.net>
References: <cover.1371177118.git.joe@perches.com>
	<43ebfe570d433155e880191f889d8b0a912257e5.1371177118.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: trivial@kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <43ebfe570d433155e880191f889d8b0a912257e5.1371177118.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Thu, 13 Jun 2013 19:37:53 -0700

> This typedef is unnecessary and should just be removed.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied.
