From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3] snmp6: remove IPSTATS_MIB_CSUMERRORS
Date: Fri, 31 May 2013 10:11:36 -0700
Message-ID: <1370020296.5109.109.camel@edumazet-glaptop>
References: <1370013236.5109.100.camel@edumazet-glaptop>
	 <1370014677-4626-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:50925 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754201Ab3EaRLh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 May 2013 13:11:37 -0400
Received: by mail-pd0-f182.google.com with SMTP id g10so2518968pdj.27
        for <netdev@vger.kernel.org>; Fri, 31 May 2013 10:11:37 -0700 (PDT)
In-Reply-To: <1370014677-4626-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-05-31 at 17:37 +0200, Nicolas Dichtel wrote:
> This stat is not relevant in IPv6, there is no checksum in IPv6 header.
> Just leave a comment to explain the hole.
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
