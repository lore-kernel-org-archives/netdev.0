From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] ip: support of usec rtt in tcp_metrics
Date: Sun, 28 Sep 2014 15:59:12 -0700
Message-ID: <20140928155912.336473f7@urahara>
References: <1409961244.26422.142.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:63162 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751465AbaI1W7Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Sep 2014 18:59:24 -0400
Received: by mail-pa0-f43.google.com with SMTP id hz1so3213030pad.16
        for <netdev@vger.kernel.org>; Sun, 28 Sep 2014 15:59:24 -0700 (PDT)
In-Reply-To: <1409961244.26422.142.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 05 Sep 2014 16:54:04 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> From: Eric Dumazet <edumazet@google.com>
> 
> Starting from linux-3.15, kernel supports new tcp metric attributes :
> TCP_METRIC_RTT_US & TCP_METRIC_RTTVAR_US
> 
> Update ip command to detect their use.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied thanks
