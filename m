From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 2/2] dccp: remove unnecessary codes in ipv6.c
Date: Mon, 02 Jul 2012 11:08:50 +0200
Message-ID: <1341220130.5269.38.camel@edumazet-glaptop>
References: <1341199140-17135-1-git-send-email-roy.qing.li@gmail.com>
	 <1341199140-17135-2-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:35402 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932310Ab2GBJIy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jul 2012 05:08:54 -0400
Received: by eeit10 with SMTP id t10so1972460eei.19
        for <netdev@vger.kernel.org>; Mon, 02 Jul 2012 02:08:53 -0700 (PDT)
In-Reply-To: <1341199140-17135-2-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-07-02 at 11:19 +0800, roy.qing.li@gmail.com wrote:
> From: RongQing.Li <roy.qing.li@gmail.com>
> 
> opt always equals np->opts, so it is meaningless to define opt, and
> check if opt does not equal np->opts and then try to free opt.
> 
> Signed-off-by: RongQing.Li <roy.qing.li@gmail.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
