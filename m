From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] netrom: avoid overflows in nr_setsockopt()
Date: Wed, 28 Dec 2011 14:08:24 -0500 (EST)
Message-ID: <20111228.140824.803334102480724987.davem@davemloft.net>
References: <1325015093-28968-1-git-send-email-xi.wang@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-hams@vger.kernel.org, netdev@vger.kernel.org,
	ralf@linux-mips.org
To: xi.wang@gmail.com
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <1325015093-28968-1-git-send-email-xi.wang@gmail.com>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Xi Wang <xi.wang@gmail.com>
Date: Tue, 27 Dec 2011 14:44:53 -0500

> Check setsockopt arguments to avoid overflows and return -EINVAL for
> too large arguments.
> 
> Signed-off-by: Xi Wang <xi.wang@gmail.com>

Applied.
