From: Daniel Baluta <dbaluta@ixiacom.com>
Subject: Re: [PATCH] net: remove empty lines from tcp_syn_flood_action
Date: Wed, 19 Mar 2014 19:33:49 +0200
Message-ID: <CAEnQRZAvziAo6CMZ2bhseHO_29zPPHvuQ2B+=z9Wn4gKPqnm6w@mail.gmail.com>
References: <1395237505-20550-1-git-send-email-dbaluta@ixiacom.com>
	<1395237505-20550-2-git-send-email-dbaluta@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Daniel Baluta <dbaluta@ixiacom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1395237505-20550-2-git-send-email-dbaluta@ixiacom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 19, 2014 at 3:58 PM, Daniel Baluta <dbaluta@ixiacom.com> wrote:
> Signed-off-by: Daniel Baluta <dbaluta@ixiacom.com>
> ---
>  net/ipv4/tcp_ipv4.c |    2 --
>  1 file changed, 2 deletions(-)
>
> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
> index c4f1d9a..4555244 100644
> --- a/net/ipv4/tcp_ipv4.c
> +++ b/net/ipv4/tcp_ipv4.c
> @@ -880,8 +880,6 @@ bool tcp_syn_flood_action(struct sock *sk,
>         bool want_cookie = false;
>         struct listen_sock *lopt;
>
> -
> -
>  #ifdef CONFIG_SYN_COOKIES
>         if (sysctl_tcp_syncookies) {
>                 msg = "Sending cookies";

Sorry for the duplicate email.
