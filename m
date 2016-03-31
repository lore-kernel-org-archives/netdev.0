From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net] rtnl: fix msg size calculation in if_nlmsg_size()
Date: Thu, 31 Mar 2016 10:13:47 -0600
Message-ID: <56FD4CBB.8070803@gmail.com>
References: <1459440631-31729-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f169.google.com ([209.85.223.169]:35061 "EHLO
	mail-io0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754767AbcCaQNz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2016 12:13:55 -0400
Received: by mail-io0-f169.google.com with SMTP id g185so121101051ioa.2
        for <netdev@vger.kernel.org>; Thu, 31 Mar 2016 09:13:55 -0700 (PDT)
In-Reply-To: <1459440631-31729-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/31/16 10:10 AM, Nicolas Dichtel wrote:
> Size of the attribute IFLA_PHYS_PORT_NAME was missing.
>
> Fixes: db24a9044ee1 ("net: add support for phys_port_name")
> CC: David Ahern <dsahern@gmail.com>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> ---
>   net/core/rtnetlink.c | 1 +
>   1 file changed, 1 insertion(+)

Acked-by: David Ahern <dsahern@gmail.com>
