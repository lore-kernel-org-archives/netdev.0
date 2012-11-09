From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] gre6: fix rtnl dump messages
Date: Fri, 09 Nov 2012 08:09:06 -0800
Message-ID: <1352477346.19779.710.camel@edumazet-glaptop>
References: <1352467361.19779.569.camel@edumazet-glaptop>
	 <1352475296-14675-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:42766 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751565Ab2KIQJI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Nov 2012 11:09:08 -0500
Received: by mail-pb0-f46.google.com with SMTP id rr4so2927943pbb.19
        for <netdev@vger.kernel.org>; Fri, 09 Nov 2012 08:09:08 -0800 (PST)
In-Reply-To: <1352475296-14675-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-11-09 at 16:34 +0100, Nicolas Dichtel wrote:
> Spotted after a code review.
> Introduced by c12b395a46646bab69089ce7016ac78177f6001f (gre: Support GRE over
> IPv6).
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> ---
> v2: rebase the patch against net
>     add the commit that introduces the bug

Thanks !

Acked-by: Eric Dumazet <edumazet@google.com>
