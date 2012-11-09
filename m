From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 4/4] gre6: fix rtnl dump messages
Date: Fri, 09 Nov 2012 05:22:41 -0800
Message-ID: <1352467361.19779.569.camel@edumazet-glaptop>
References: <1352454671-4336-1-git-send-email-nicolas.dichtel@6wind.com>
	 <1352454671-4336-5-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:51968 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751880Ab2KINWn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Nov 2012 08:22:43 -0500
Received: by mail-ie0-f174.google.com with SMTP id k13so5836336iea.19
        for <netdev@vger.kernel.org>; Fri, 09 Nov 2012 05:22:43 -0800 (PST)
In-Reply-To: <1352454671-4336-5-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-11-09 at 10:51 +0100, Nicolas Dichtel wrote:
> Spotted after a code review.
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> ---
>  net/ipv6/ip6_gre.c | 8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)

Hi Nicolas

Could you please write real changelogs ?

This is a bug fix.

So we need for proper tracking of this bug, a reference
of the original commit that introduced this bug.

This will help stable teams work tremendously

Thanks !
