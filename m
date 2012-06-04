From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH iproute2] Add reference to tc-codel(8) to the SEE ALSO
 section
Date: Mon, 4 Jun 2012 12:03:24 -0700
Message-ID: <20120604120324.3b34cfa4@nehalam.linuxnetplumber.net>
References: <1338666310-18744-1-git-send-email-jan.ceuleers@computer.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: andyqos@ukfsn.org, netdev@vger.kernel.org
To: Jan Ceuleers <jan.ceuleers@computer.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:42779 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752391Ab2FDTD2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jun 2012 15:03:28 -0400
In-Reply-To: <1338666310-18744-1-git-send-email-jan.ceuleers@computer.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat,  2 Jun 2012 21:45:10 +0200
Jan Ceuleers <jan.ceuleers@computer.org> wrote:

> Reported-by: Andy Furniss <andyqos@ukfsn.org>
> Signed-off-by: Jan Ceuleers <jan.ceuleers@computer.org>
> ---
>  man/man8/tc.8 |    1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/man/man8/tc.8 b/man/man8/tc.8
> index 6576377..14a1cd8 100644
> --- a/man/man8/tc.8
> +++ b/man/man8/tc.8
> @@ -368,6 +368,7 @@ was written by Alexey N. Kuznetsov and added in Linux 2.2.
>  .SH SEE ALSO
>  .BR tc-cbq (8),
>  .BR tc-choke (8),
> +.BR tc-codel (8),
>  .BR tc-drr (8),
>  .BR tc-htb (8),
>  .BR tc-hfsc (8),

applied.
