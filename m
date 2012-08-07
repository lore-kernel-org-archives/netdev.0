From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 3/5 (resend)] veth: Allow to create peer link with
 given ifindex
Date: Tue, 07 Aug 2012 15:14:09 +0200
Message-ID: <1344345249.28967.90.camel@edumazet-glaptop>
References: <501FD0F2.4040609@parallels.com>
	 <501FD14F.2040209@parallels.com>  <5020F5AB.3090101@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:58223 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753661Ab2HGNON (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Aug 2012 09:14:13 -0400
Received: by mail-bk0-f46.google.com with SMTP id j10so1439595bkw.19
        for <netdev@vger.kernel.org>; Tue, 07 Aug 2012 06:14:12 -0700 (PDT)
In-Reply-To: <5020F5AB.3090101@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-08-07 at 15:02 +0400, Pavel Emelyanov wrote:
> The ifinfomsg is in there (thanks kaber@ for foreseeing this long time ago),
> so take the given ifidex and register netdev with it.
> 
> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
> ---
>  drivers/net/veth.c |    3 +++
>  1 files changed, 3 insertions(+), 0 deletions(-)

Acked-by: Eric Dumazet <edumazet@google.com>
