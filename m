From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] ip: Added missing usage for netconf object
Date: Tue, 15 Jul 2014 09:43:34 -0700
Message-ID: <20140715094334.69fdd862@haswell>
References: <1404139070-14177-1-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: vadimk <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:62095 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752881AbaGOQnc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2014 12:43:32 -0400
Received: by mail-pd0-f170.google.com with SMTP id g10so5189175pdj.29
        for <netdev@vger.kernel.org>; Tue, 15 Jul 2014 09:43:32 -0700 (PDT)
In-Reply-To: <1404139070-14177-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 30 Jun 2014 17:37:50 +0300
vadimk <vadim4j@gmail.com> wrote:

> ---
>  ip/ip.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/ip/ip.c b/ip/ip.c
> index 813fabd..739b88d 100644
> --- a/ip/ip.c
> +++ b/ip/ip.c
> @@ -45,7 +45,7 @@ static void usage(void)
>  "       ip [ -force ] -batch filename\n"
>  "where  OBJECT := { link | addr | addrlabel | route | rule | neigh | ntable |\n"
>  "                   tunnel | tuntap | maddr | mroute | mrule | monitor | xfrm |\n"
> -"                   netns | l2tp | tcp_metrics | token }\n"
> +"                   netns | l2tp | tcp_metrics | token | netconf }\n"
>  "       OPTIONS := { -V[ersion] | -s[tatistics] | -d[etails] | -r[esolve] |\n"
>  "                    -f[amily] { inet | inet6 | ipx | dnet | bridge | link } |\n"
>  "                    -4 | -6 | -I | -D | -B | -0 |\n"

accepted
