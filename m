From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6 1/3] cxgb3: remove call to stop TX queues at
 load time.
Date: Mon, 01 Nov 2010 14:10:13 -0700 (PDT)
Message-ID: <20101101.141013.35028696.davem@davemloft.net>
References: <20101101205940.27716.24553.stgit@speedy5.asicdesigners.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	dm@chelsio.com, leedom@chelsio.com, swise@opengridcomputing.com
To: divy@chelsio.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101101205940.27716.24553.stgit@speedy5.asicdesigners.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Divy Le Ray <divy@chelsio.com>
Date: Mon, 01 Nov 2010 13:59:41 -0700

> From: Divy Le Ray <divy@chelsio.com>
> 
> Remove racy queue stopping after device registration.
> 
> Signed-off-by: Divy Le Ray <divy@chelsio.com>

Applied.
