From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] caif: remove unused struct member
Date: Wed, 01 Apr 2015 12:43:22 -0400 (EDT)
Message-ID: <20150401.124322.2224846262582355297.davem@davemloft.net>
References: <1427810723-21234-1-git-send-email-linux@rasmusvillemoes.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dmitry.tarnyagin@lockless.no, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linux@rasmusvillemoes.dk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1427810723-21234-1-git-send-email-linux@rasmusvillemoes.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Date: Tue, 31 Mar 2015 16:05:23 +0200

> The tty_name member of struct ser_device is never set or used, so it
> can be removed. (The definition of struct ser_device is private to
> this .c file, and the identifier tty_name only occurs in this one
> place.)
> 
> Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>

Applied, thanks.
