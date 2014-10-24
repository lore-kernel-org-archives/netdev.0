From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: typhoon: Remove redundant casts
Date: Fri, 24 Oct 2014 00:41:59 -0400 (EDT)
Message-ID: <20141024.004159.1994894378428875914.davem@davemloft.net>
References: <1413903103-3047-1-git-send-email-linux@rasmusvillemoes.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dave@thedillows.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linux@rasmusvillemoes.dk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1413903103-3047-1-git-send-email-linux@rasmusvillemoes.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Date: Tue, 21 Oct 2014 16:51:43 +0200

> Both image_data and typhoon_fw->data are const u8*, so the cast to u8*
> is unnecessary and confusing.
> 
> Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>

Applied.
