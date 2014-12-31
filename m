From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tun: Fixed unsigned/signed comparison
Date: Wed, 31 Dec 2014 14:15:19 -0500 (EST)
Message-ID: <20141231.141519.1699158219787680373.davem@davemloft.net>
References: <1419577503-12862-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-team@fb.com
To: agartrell@fb.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1419577503-12862-1-git-send-email-agartrell@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alex Gartrell <agartrell@fb.com>
Date: Thu, 25 Dec 2014 23:05:03 -0800

> Validated that this was actually using the unsigned comparison with gdb.
> 
> Signed-off-by: Alex Gartrell <agartrell@fb.com>

Applied.
