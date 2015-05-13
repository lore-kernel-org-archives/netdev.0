From: Ying Xue <ying.xue@windriver.com>
Subject: Re: [PATCH net-next] neigh: fix a possible leak issue of neigh entry
Date: Wed, 13 May 2015 15:25:01 +0800
Message-ID: <5552FC4D.3060200@windriver.com>
References: <1431495814-22759-1-git-send-email-ying.xue@windriver.com> <1431498048.566.131.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:52854 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752543AbbEMH01 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 03:26:27 -0400
In-Reply-To: <1431498048.566.131.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/13/2015 02:20 PM, Eric Dumazet wrote:
> Have you hit this condition ?
> 

No, I just found the issue when I was reading the code.

> If yes, there is a bug elsewhere and we need to fix it, not trying to
> recover.
> 

Sorry, I don't know its relevant story, so can you please give some hints?

Thanks,
Ying
