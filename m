From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net-next 2/2] net: sctp: trivial: add uapi/linux/sctp.h
 into maintainers
Date: Tue, 23 Jul 2013 10:39:50 -0400
Message-ID: <51EE95B6.8080809@gmail.com>
References: <1374583908-17152-1-git-send-email-dborkman@redhat.com> <1374583908-17152-2-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f173.google.com ([209.85.216.173]:51095 "EHLO
	mail-qc0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757575Ab3GWOjy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jul 2013 10:39:54 -0400
In-Reply-To: <1374583908-17152-2-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/23/2013 08:51 AM, Daniel Borkmann wrote:
> After this file has moved to the uapi section, we also need to update
> this in the maintainers file.
>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Acked-by: Vlad Yasevich <vyasevich@gmail.com>

> ---
>   MAINTAINERS | 1 +
>   1 file changed, 1 insertion(+)
>
> diff --git a/MAINTAINERS b/MAINTAINERS
> index bf61e04..339e798 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -7216,6 +7216,7 @@ W:	http://lksctp.sourceforge.net
>   S:	Maintained
>   F:	Documentation/networking/sctp.txt
>   F:	include/linux/sctp.h
> +F:	include/uapi/linux/sctp.h
>   F:	include/net/sctp/
>   F:	net/sctp/
>
>
