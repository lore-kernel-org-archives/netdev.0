From: Junchang Wang <junchangwang@gmail.com>
Subject: Re: [PATCH net-next] r8169: Add 64bit statistics
Date: Fri, 18 Nov 2011 10:24:56 +0800
Message-ID: <CABoNC816GL4vqbHSR8BYrOFFuL_ZSqxS1xqmG02uwpKkwKNJDQ@mail.gmail.com>
References: <20111117064826.GA4429@Desktop-Junchang>
	<20111117093635.GA9112@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: nic_swsd@realtek.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:51891 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755605Ab1KRCY5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2011 21:24:57 -0500
Received: by vcbfk1 with SMTP id fk1so2568654vcb.19
        for <netdev@vger.kernel.org>; Thu, 17 Nov 2011 18:24:57 -0800 (PST)
In-Reply-To: <20111117093635.GA9112@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> The 816x chipsets have hardware stats registers. The driver already
> use them. Please use them more.

Hi Francois,

I'm not sure which hardware stats registers are accurate. Besides, it
seem r8169.c are also designed for other chipsets (8129?).

I would like other people who are quite familiar with those chipsets
to do this job.

Is that OK? Thanks.

-- 
--Junchang
