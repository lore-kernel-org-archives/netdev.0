From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: Fix comments for Nagle algorithm
Date: Tue, 08 Nov 2011 14:03:12 -0500 (EST)
Message-ID: <20111108.140312.2104080830131697151.davem@davemloft.net>
References: <1320503003-5169-1-git-send-email-kinwin2008@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: kinwin2008@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1320503003-5169-1-git-send-email-kinwin2008@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Feng King <kinwin2008@gmail.com>
Date: Sat,  5 Nov 2011 22:23:23 +0800

> TCP_NODELAY is weaker than TCP_CORK, when TCP_CORK was set, small
> segments will always pass Nagle test regardless of TCP_NODELAY option.
> 
> Signed-off-by: Feng King <kinwin2008@gmail.com>

Applied, thanks.
