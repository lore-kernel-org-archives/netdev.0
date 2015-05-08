From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH iproute2] ss: dctcp changes
Date: Fri, 08 May 2015 22:46:18 +0200
Message-ID: <554D209A.6070702@iogearbox.net>
References: <1431116920.22756.18.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:45086 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752220AbbEHUqW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 May 2015 16:46:22 -0400
In-Reply-To: <1431116920.22756.18.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/08/2015 10:28 PM, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> Missing space before dctcp: markers.
>
> With dctcp, cwnd=2 is pretty common, just display cwnd value even
> if cwnd has this value, it makes parsing easier.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Thanks Eric!

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
