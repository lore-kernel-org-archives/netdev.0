From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] ss: Change "do now" to "do not" in ss(8), -n option
Date: Wed, 8 Dec 2010 07:55:48 -0800
Message-ID: <20101208075548.78d9a8ad@nehalam>
References: <1291816149-15782-1-git-send-email-psabata@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Petr Sabata <psabata@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:57060 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755986Ab0LHPzu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Dec 2010 10:55:50 -0500
In-Reply-To: <1291816149-15782-1-git-send-email-psabata@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed,  8 Dec 2010 14:49:09 +0100
Petr Sabata <psabata@redhat.com> wrote:

> A small typo fix.
> 
> ---
>  man/man8/ss.8 |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/man/man8/ss.8 b/man/man8/ss.8
> index f261cf2..b309df2 100644
> --- a/man/man8/ss.8
> +++ b/man/man8/ss.8
> @@ -26,7 +26,7 @@ Show summary of options.
>  Output version information.
>  .TP
>  .B \-n, \-\-numeric
> -Do now try to resolve service names.
> +Do not try to resolve service names.
>  .TP
>  .B \-r, \-\-resolve
>  Try to resolve numeric address/ports.

applied

-- 
