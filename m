From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] pkt_sched: fq: Fair Queue packet scheduler
Date: Tue, 3 Sep 2013 08:49:57 -0700
Message-ID: <20130903084957.71d67cf3@nehalam.linuxnetplumber.net>
References: <1377816595.8277.54.camel@edumazet-glaptop>
	<20130829.214730.2158572637993114547.davem@davemloft.net>
	<1377829836.8277.59.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	ycheng@google.com, ncardwell@google.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:59120 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755405Ab3ICPuB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Sep 2013 11:50:01 -0400
Received: by mail-pa0-f42.google.com with SMTP id lj1so6629405pab.29
        for <netdev@vger.kernel.org>; Tue, 03 Sep 2013 08:50:00 -0700 (PDT)
In-Reply-To: <1377829836.8277.59.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 29 Aug 2013 19:30:36 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> From: Eric Dumazet <edumazet@google.com>
> 
> Support for FQ packet scheduler

Applied to net-next-3.11 branch, with some minor cleanups.
