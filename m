From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] ping doc: Fix typo.
Date: Sat, 19 Jan 2013 03:20:55 +0900
Message-ID: <50F99287.7000805@linux-ipv6.org>
References: <1358508096-19915-1-git-send-email-jsynacek@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Jan Synacek <jsynacek@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:45993 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751881Ab3ARSU5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jan 2013 13:20:57 -0500
In-Reply-To: <1358508096-19915-1-git-send-email-jsynacek@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(2013年01月18日 20:21), Jan Synacek wrote:
> Signed-off-by: Jan Synacek <jsynacek@redhat.com>
> ---
>  doc/ping.sgml | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/doc/ping.sgml b/doc/ping.sgml
> index 4e0e65f..eec92a2 100644
> --- a/doc/ping.sgml
> +++ b/doc/ping.sgml
> @@ -600,7 +600,7 @@ Many Hosts and Gateways ignore the RECORD_ROUTE option.
>   <listitem><para>
>  The maximum IP header length is too small for options like
>  RECORD_ROUTE to be completely useful.
> -There's not much that that can be done about this, however.
> +There's not much that can be done about this, however.
>   </para></listitem>
>   <listitem><para>
>  Flood pinging is not recommended in general, and flood pinging the
> 

Applied, thanks.

--yoshfuji
