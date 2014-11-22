From: Vincent JARDIN <vincent.jardin@6wind.com>
Subject: Re: [RFC PATCH 1/4] rtnetlink: new flag NLM_F_HW_OFFLOAD to indicate
 kernel object offload to hardware
Date: Sat, 22 Nov 2014 23:03:38 +0100
Message-ID: <5471083A.7050701@6wind.com>
References: <1416610170-21224-2-git-send-email-roopa@cumulusnetworks.com> <20141121231234.GA20810@casper.infradead.org> <546FD467.5030602@cumulusnetworks.com> <20141122122936.GD20810@casper.infradead.org> <5470E5E0.9070005@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, jiri@resnulli.us, sfeldma@gmail.com,
	jhs@mojatatu.com, bcrl@kvack.org, john.fastabend@gmail.com,
	stephen@networkplumber.org, linville@tuxdriver.com,
	nhorman@tuxdriver.com, nicolas.dichtel@6wind.com,
	vyasevic@redhat.com, f.fainelli@gmail.com, buytenh@wantstofly.org,
	aviadr@mellanox.com, netdev@vger.kernel.org, davem@davemloft.net,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>,
	gospo@cumulusnetworks.com
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:53233 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750778AbaKVWDn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Nov 2014 17:03:43 -0500
Received: by mail-wi0-f172.google.com with SMTP id n3so2358318wiv.17
        for <netdev@vger.kernel.org>; Sat, 22 Nov 2014 14:03:42 -0800 (PST)
In-Reply-To: <5470E5E0.9070005@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 22/11/2014 20:37, Roopa Prabhu wrote:
> struct ifinfomsg -> ifi_flags
> struct ndmsg ->ndm_flags
> struct rtmsg  -> rtm_flags
>
> If this is preferred .., I can repost the series with these changes.

Yes, it would be my preferred too.

Thank you,
   Vincent
