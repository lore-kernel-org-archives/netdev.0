From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] tc: more user friendly rates
Date: Tue, 3 Dec 2013 00:08:29 -0800
Message-ID: <20131203000829.152f8d65@nehalam.linuxnetplumber.net>
References: <1385102237.10637.82.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:46118 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751067Ab3LCIIc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Dec 2013 03:08:32 -0500
Received: by mail-pb0-f52.google.com with SMTP id uo5so20568404pbc.39
        for <netdev@vger.kernel.org>; Tue, 03 Dec 2013 00:08:32 -0800 (PST)
In-Reply-To: <1385102237.10637.82.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 21 Nov 2013 22:37:17 -0800
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> From: Eric Dumazet <edumazet@google.com>
> 
> Display more user friendly rates.
> 
> 10Mbit is more readable than 10000Kbit
> 
> Before : 
> class htb 1:2 root prio 0 rate 10000Kbit ceil 10000Kbit ...
> 
> After:
> class htb 1:2 root prio 0 rate 10Mbit ceil 10Mbit ...
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Sure, accepted.
