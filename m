From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH iproute2] netem: Add missing '}' in man page
Date: Thu, 19 Jan 2012 14:11:19 -0800
Message-ID: <20120119141119.7354fe19@nehalam.linuxnetplumber.net>
References: <1327007823-19826-1-git-send-email-subramanian.vijay@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vijay Subramanian <subramanian.vijay@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:34987 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754134Ab2ASWLW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jan 2012 17:11:22 -0500
In-Reply-To: <1327007823-19826-1-git-send-email-subramanian.vijay@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 19 Jan 2012 13:17:03 -0800
Vijay Subramanian <subramanian.vijay@gmail.com> wrote:

> Signed-off-by: Vijay Subramanian <subramanian.vijay@gmail.com>
> ---
>  man/man8/tc-netem.8 |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/man/man8/tc-netem.8 b/man/man8/tc-netem.8
> index e6f2616..873608e 100644
> --- a/man/man8/tc-netem.8
> +++ b/man/man8/tc-netem.8
> @@ -31,6 +31,7 @@ NetEm \- Network Emulator
>  .br
>  .RB "               " gemodel
>  .IR p " [ " r " [ " 1-h " [ " 1-k " ]]]"
> +.BR " }"
>  
>  .IR CORRUPT " := "
>  .B corrupt

Applied.
