From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] tc: support TCA_STATS_RATE_EST64
Date: Fri, 20 Sep 2013 09:47:43 -0700
Message-ID: <20130920094743.34a9c433@nehalam.linuxnetplumber.net>
References: <1379416743.29845.15.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:61903 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752302Ab3ITQrq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Sep 2013 12:47:46 -0400
Received: by mail-pa0-f48.google.com with SMTP id kp13so927714pab.35
        for <netdev@vger.kernel.org>; Fri, 20 Sep 2013 09:47:46 -0700 (PDT)
In-Reply-To: <1379416743.29845.15.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 17 Sep 2013 04:19:03 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> From: Eric Dumazet <edumazet@google.com>
> 
> Since linux-3.11, rate estimator can provide TCA_STATS_RATE_EST64
> when rate (bytes per second) is above 2^32 (~34 Mbits)
> 
> Change tc to use this attribute for high rates.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---

Applied
