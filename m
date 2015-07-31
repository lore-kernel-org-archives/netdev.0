From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Problem with fragmented packets on tun/tap interface
Date: Fri, 31 Jul 2015 09:56:35 +0200
Message-ID: <1438329395.2748.1.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAPBAu3WwLLAYtRuxrA2uDF7J5-1FPfvJ-JVB1_WHNZdf1W_M=A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Prashant Upadhyaya <praupadhyaya@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:36408 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751342AbbGaH4j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jul 2015 03:56:39 -0400
Received: by wicgj17 with SMTP id gj17so6109753wic.1
        for <netdev@vger.kernel.org>; Fri, 31 Jul 2015 00:56:38 -0700 (PDT)
In-Reply-To: <CAPBAu3WwLLAYtRuxrA2uDF7J5-1FPfvJ-JVB1_WHNZdf1W_M=A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-07-31 at 12:30 +0530, Prashant Upadhyaya wrote:

> The delays work for me but is clearly not good for the performance of
> the slow path. And more importantly, I was looking for a fundamental
> reason regarding why it works with delays and why not without it. The
> issue is reproducible with a big ping (3.11.10-301.fc20.x86_64)

How big ping needs to be to reproduce the problem ?
