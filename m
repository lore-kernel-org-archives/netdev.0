From: Matthew Wilcox <matthew@wil.cx>
Subject: Re: [2.6 patch] unexport dev_ethtool
Date: Tue, 14 Aug 2007 15:23:26 -0600
Message-ID: <20070814212325.GW16277@parisc-linux.org>
References: <20070814212203.GV18945@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Adrian Bunk <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palinux.external.hp.com ([192.25.206.14]:55201 "EHLO
	mail.parisc-linux.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756770AbXHNVXc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Aug 2007 17:23:32 -0400
Content-Disposition: inline
In-Reply-To: <20070814212203.GV18945@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 14, 2007 at 11:22:03PM +0200, Adrian Bunk wrote:
> This patch removes the no longer used EXPORT_SYMBOL(dev_ethtool).
> 
> Signed-off-by: Adrian Bunk <bunk@kernel.org>
Acked-by: Matthew Wilcox <matthew@wil.cx>

-- 
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."
