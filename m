From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 0/2] Add PHY IRQ support to the 'sh_eth' driver
Date: Fri, 20 Dec 2013 01:43:16 +0300
Message-ID: <52B37684.5030206@cogentembedded.com>
References: <201312200138.09307.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f44.google.com ([209.85.215.44]:53446 "EHLO
	mail-la0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756437Ab3LSVnI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 16:43:08 -0500
Received: by mail-la0-f44.google.com with SMTP id ep20so733154lab.17
        for <netdev@vger.kernel.org>; Thu, 19 Dec 2013 13:43:07 -0800 (PST)
In-Reply-To: <201312200138.09307.sergei.shtylyov@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/20/2013 01:38 AM, Sergei Shtylyov wrote:

>     This patchset adds support for passing PHY's IRQ to the 'sh_eth' driver from
> the platform code and removes now useless code that hinders the PHY IRQ handing
> by philib.

    Ugh, forgot to mention it's against DaveM's 'net-next.git' repo.

> [1/2] sh_eth: add PHY IRQ to platform data
> [2/2] sh_eth: do not reset PHY needlessly

WBR, Sergei
