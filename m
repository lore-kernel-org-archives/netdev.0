From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3] bgmac: add support for Byte Queue Limits
Date: Sun, 29 Sep 2013 21:34:44 -0700
Message-ID: <1380515684.3596.23.camel@edumazet-glaptop.roam.corp.google.com>
References: <1380455698-5897-1-git-send-email-hauke@hauke-m.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, zajec5@gmail.com, netdev@vger.kernel.org
To: Hauke Mehrtens <hauke@hauke-m.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f50.google.com ([209.85.160.50]:43443 "EHLO
	mail-pb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751051Ab3I3Eeq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Sep 2013 00:34:46 -0400
Received: by mail-pb0-f50.google.com with SMTP id uo5so5074222pbc.9
        for <netdev@vger.kernel.org>; Sun, 29 Sep 2013 21:34:46 -0700 (PDT)
In-Reply-To: <1380455698-5897-1-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-09-29 at 13:54 +0200, Hauke Mehrtens wrote:
> This makes it possible to use some more advanced queuing
> techniques with this driver.
> 
> When multi queue support will be added some changes to Byte Queue
> handling is needed.
> 
> Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
> ---

Reviewed-by: Eric Dumazet <edumazet@google.com>
