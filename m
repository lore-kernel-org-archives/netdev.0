From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next] net: filter: add test_bpf module under
 MAINTAINERS' networking section
Date: Tue, 10 Jun 2014 07:25:06 -0700
Message-ID: <CAMEtUuy=rSV6ttr9V9cK4DDtYUBm3V=7pu42ukkDyvMTqK67Bg@mail.gmail.com>
References: <1402396270-9726-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f173.google.com ([74.125.82.173]:59133 "EHLO
	mail-we0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750788AbaFJOZI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jun 2014 10:25:08 -0400
Received: by mail-we0-f173.google.com with SMTP id t60so758005wes.4
        for <netdev@vger.kernel.org>; Tue, 10 Jun 2014 07:25:07 -0700 (PDT)
In-Reply-To: <1402396270-9726-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 10, 2014 at 3:31 AM, Daniel Borkmann <dborkman@redhat.com> wrote:
> Add lib/test_bpf.c entry to maintainers file under networking.
> All changes were posted via netdev for review, so make sure
> other people Cc it as well when they call get_maintainer.pl.
>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> Cc: Alexei Starovoitov <ast@plumgrid.com>
> ---

Acked-by: Alexei Starovoitov <ast@plumgrid.com>

>  MAINTAINERS | 1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/MAINTAINERS b/MAINTAINERS
> index 7a06ea4..05dafe1 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -6130,6 +6130,7 @@ F:        include/uapi/linux/netdevice.h
>  F:     tools/net/
>  F:     tools/testing/selftests/net/
>  F:     lib/random32.c
> +F:     lib/test_bpf.c
>
>  NETWORKING [IPv4/IPv6]
>  M:     "David S. Miller" <davem@davemloft.net>
> --
> 1.7.11.7
>
