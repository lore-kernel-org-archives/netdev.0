From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] man ip-link: Fix indentation for 'ip link
 show' options
Date: Wed, 3 Dec 2014 09:18:29 -0800
Message-ID: <20141203091829.7906b1df@urahara>
References: <1417552751-3132-1-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:49807 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750963AbaLCRSj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2014 12:18:39 -0500
Received: by mail-pa0-f48.google.com with SMTP id rd3so16121610pab.7
        for <netdev@vger.kernel.org>; Wed, 03 Dec 2014 09:18:39 -0800 (PST)
In-Reply-To: <1417552751-3132-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue,  2 Dec 2014 22:39:11 +0200
Vadim Kochan <vadim4j@gmail.com> wrote:

> BEFORE:
>               The show command has additional formatting options:
> 
>        -s, -stats, -statistics
>               output more statistics about packet usage.
> 
>        -d, -details
>               output more detailed information.
> 
>        -h, -human, -human-readble
>               output statistics with human readable values number followed by suffix
> 
>        -iec   print human readable rates in IEC units (ie. 1K = 1024).
> AFTER:
>        The show command has additional formatting options:
> 
>               -s, -stats, -statistics
>                      output more statistics about packet usage.
> 
>               -d, -details
>                      output more detailed information.
> 
>               -h, -human, -human-readble
>                      output statistics with human readable values number followed by suffix
> 
>               -iec   print human readable rates in IEC units (ie. 1K = 1024).
> 
> Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
> ---
>  man/man8/ip-link.8.in | 3 +++
>  1 file changed, 3 insertions(+)

Applied
