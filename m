From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: addrconf.c: remove unnecessary "if"
Date: Wed, 19 Dec 2012 12:51:05 -0800 (PST)
Message-ID: <20121219.125105.474504972221301066.davem@davemloft.net>
References: <1355868536-1622-1-git-send-email-dinggnu@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: dinggnu@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1355868536-1622-1-git-send-email-dinggnu@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Cong Ding <dinggnu@gmail.com>
Date: Tue, 18 Dec 2012 23:08:56 +0100

> the value of err is always negative if it goes to errout, so we don't need to
> check the value of err.
> 
> Signed-off-by: Cong Ding <dinggnu@gmail.com>

Applied.
