From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] iproute2: fix tc ematch manpage section
Date: Wed, 12 Dec 2012 08:16:06 -0800
Message-ID: <20121212081606.3df8c72d@nehalam.linuxnetplumber.net>
References: <20121212112348.GA6520@amd64.fatal.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andreas Henriksson <andreas@fatal.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:54413 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754290Ab2LLQRW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Dec 2012 11:17:22 -0500
In-Reply-To: <20121212112348.GA6520@amd64.fatal.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 12 Dec 2012 12:23:48 +0100
Andreas Henriksson <andreas@fatal.se> wrote:

> The debian package checking tool, lintian, spotted that the
> tc ematch manpage seems to have an error in the specified section.
> 
> Signed-off-by: Andreas Henriksson <andreas@fatal.se>
> 
> diff --git a/man/man8/tc-ematch.8 b/man/man8/tc-ematch.8
> index 2eafc29..957a22e 100644
> --- a/man/man8/tc-ematch.8
> +++ b/man/man8/tc-ematch.8
> @@ -1,4 +1,4 @@
> -.TH filter ematch "6 August 2012" iproute2 Linux
> +.TH ematch 8 "6 August 2012" iproute2 Linux
>  .
>  .SH NAME
>  ematch \- extended matches for use with "basic" or "flow" filters

Applied, thanks.
