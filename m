From: Patrick McHardy <kaber@trash.net>
Subject: Re: [IPROUTE2 PATCH] Interface group as new ip link option
Date: Tue, 16 Oct 2007 10:38:42 +0200
Message-ID: <47147892.4090801@trash.net>
References: <1192521703479-git-send-email-panther@balabit.hu> <11925217031287-git-send-email-panther@balabit.hu> <11925217031728-git-send-email-panther@balabit.hu> <1192521703205-git-send-email-panther@balabit.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Laszlo Attila Toth <panther@balabit.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34540 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757458AbXJPIi6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2007 04:38:58 -0400
In-Reply-To: <1192521703205-git-send-email-panther@balabit.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Laszlo Attila Toth wrote:
> diff --git a/man/man8/ip.8 b/man/man8/ip.8
> index c74440a..8e6a9a3 100644
> --- a/man/man8/ip.8
> +++ b/man/man8/ip.8
> @@ -511,6 +511,11 @@ already configured.
> @@ -1835,3 +1840,6 @@ was written by Alexey N. Kuznetsov and added in Linux 2.2.
>  
>  .SH AUTHOR
>  Original Manpage  by Michail Litvak <mci@owl.openwall.com>
> +.br
> +Modified for ZorpOS by Tamas Pal <folti@balabit.hu>


Did you really intend to include this?
