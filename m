From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] lwtunnel: export linux/lwtunnel.h to userspace
Date: Thu, 23 Jul 2015 06:46:37 -0700
Message-ID: <55B0F03D.4060100@cumulusnetworks.com>
References: <1437659036-14282-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Thomas Graf <tgraf@suug.ch>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:36008 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752153AbbGWNqk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jul 2015 09:46:40 -0400
Received: by pachj5 with SMTP id hj5so157886165pac.3
        for <netdev@vger.kernel.org>; Thu, 23 Jul 2015 06:46:39 -0700 (PDT)
In-Reply-To: <1437659036-14282-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/23/15, 6:43 AM, Nicolas Dichtel wrote:
> Note also that include/linux/lwtunnel.h is not needed.
>
> CC: Thomas Graf <tgraf@suug.ch>
> CC: Roopa Prabhu <roopa@cumulusnetworks.com>
> Fixes: 499a24256862 ("lwtunnel: infrastructure for handling light weight tunnels like mpls")
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>
Acked-by: Roopa Prabhu <roopa@cumulusnetworks.com>

Thanks.
