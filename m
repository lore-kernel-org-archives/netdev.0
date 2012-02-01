From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mISDN: use memchr_inv
Date: Wed, 01 Feb 2012 14:15:51 -0500 (EST)
Message-ID: <20120201.141551.1696887866364021374.davem@davemloft.net>
References: <1327674295-3700-1-git-send-email-akinobu.mita@gmail.com>
	<1327674295-3700-8-git-send-email-akinobu.mita@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	isdn@linux-pingi.de, netdev@vger.kernel.org
To: akinobu.mita@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1327674295-3700-8-git-send-email-akinobu.mita@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Akinobu Mita <akinobu.mita@gmail.com>
Date: Fri, 27 Jan 2012 23:24:55 +0900

> Use memchr_inv to check if the data contains all same bytes.  It is
> faster than looping for each byte.
> 
> Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>

Applied, thanks.
