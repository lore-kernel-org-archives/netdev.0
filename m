From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] ip: Few typo and grammar errors fixes for ip(8) manpage
Date: Thu, 16 Dec 2010 09:33:00 -0800
Message-ID: <20101216093300.7d85bd77@nehalam>
References: <1292516694-9156-1-git-send-email-psabata@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Petr Sabata <psabata@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:52578 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756767Ab0LPRdD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Dec 2010 12:33:03 -0500
In-Reply-To: <1292516694-9156-1-git-send-email-psabata@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 16 Dec 2010 17:24:54 +0100
Petr Sabata <psabata@redhat.com> wrote:

> ---
>  man/man8/ip.8 |    6 +++---
>  1 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/man/man8/ip.8 b/man/man8/ip.8
> index 6c778d2..8d55fa9 100644
> --- a/man/man8/ip.8
> +++ b/man/man8/ip.8
> @@ -1289,7 +1289,7 @@ can also be
>  .BI nud " NUD_STATE"
>  the state of the neighbour entry.
>  .B nud
> -is an abbreviation for 'Neigh bour Unreachability Detection'.
> +is an abbreviation for 'Neighbour Unreachability Detection'.
>  The state can take one of the following values:
>  
>  .in +8
> @@ -1614,7 +1614,7 @@ peers are allowed to send to us.
>  .BI rtt " TIME"
>  the initial RTT ('Round Trip Time') estimate. If no suffix is
>  specified the units are raw values passed directly to the
> -routing code to maintain compatability with previous releases.
> +routing code to maintain compatibility with previous releases.
>  Otherwise if a suffix of s, sec or secs is used to specify
>  seconds; ms, msec or msecs to specify milliseconds; us, usec
>  or usecs to specify microseconds; ns, nsec or nsecs to specify
> @@ -2484,7 +2484,7 @@ contains one or more algorithms
>  .I ALGO
>  which depend on the type of algorithm set by
>  .IR ALGO_TYPE "."
> -It can be used these algoritms
> +Valid algorithms are:
>  .BR enc ", " auth " or " comp "."
>  
>  .SS ip xfrm policy add - add a new policy

Applied.

-- 
