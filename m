From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH] net: netfilter: nfnetlink: Fixed warning for
 nfnl_get_lock
Date: Mon, 4 Mar 2013 22:42:29 +0100
Message-ID: <20130304214229.GF22274@pd.tnic>
References: <1362426192-2921-1-git-send-email-gheorghiuandru@gmail.com>
 <20130304210551.GA22306@pd.tnic>
 <20130304212338.GA3594@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Alexandru Gheorghiu <gheorghiuandru@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.skyhub.de ([78.46.96.112]:50962 "EHLO mail.skyhub.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932254Ab3CDVmq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Mar 2013 16:42:46 -0500
Content-Disposition: inline
In-Reply-To: <20130304212338.GA3594@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 04, 2013 at 10:23:38PM +0100, Pablo Neira Ayuso wrote:
> Already got a fix for compilation warning in my tree:
> 
> http://1984.lsi.us.es/git/nf/commit/?id=9df9e7832391cf699abbf39fc8d95d7e78297462

And it even explains why gcc complains.

Thanks.

-- 
Regards/Gruss,
    Boris.

Sent from a fat crate under my desk. Formatting is fine.
--
