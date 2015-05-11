From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] ss: dctcp changes
Date: Mon, 11 May 2015 09:17:08 -0700
Message-ID: <20150511091708.52b8dc4e@urahara>
References: <1431116920.22756.18.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:35458 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753569AbbEKQRE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2015 12:17:04 -0400
Received: by pabtp1 with SMTP id tp1so113604015pab.2
        for <netdev@vger.kernel.org>; Mon, 11 May 2015 09:17:04 -0700 (PDT)
In-Reply-To: <1431116920.22756.18.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 08 May 2015 13:28:40 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> From: Eric Dumazet <edumazet@google.com>
> 
> Missing space before dctcp: markers.
> 
> With dctcp, cwnd=2 is pretty common, just display cwnd value even
> if cwnd has this value, it makes parsing easier.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks
