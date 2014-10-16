From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH 1/1 net-next] openvswitch: kerneldoc warning fix
Date: Wed, 15 Oct 2014 18:12:15 -0700
Message-ID: <CALnjE+qap-kXC6DaALqc0S=a8oNjyuEu8B-_8dBLQ3NtHr8Ytw@mail.gmail.com>
References: <1413399798-8514-1-git-send-email-fabf@skynet.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: LKML <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>
To: Fabian Frederick <fabf@skynet.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na6sys009bog024.obsmtp.com ([74.125.150.88]:33051 "HELO
	na6sys009bog024.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750820AbaJPBMX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Oct 2014 21:12:23 -0400
Received: by mail-ig0-f173.google.com with SMTP id h18so18507456igc.6
        for <netdev@vger.kernel.org>; Wed, 15 Oct 2014 18:12:15 -0700 (PDT)
In-Reply-To: <1413399798-8514-1-git-send-email-fabf@skynet.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 15, 2014 at 12:03 PM, Fabian Frederick <fabf@skynet.be> wrote:
> s/sock/gs
>
> Signed-off-by: Fabian Frederick <fabf@skynet.be>

Looks good.

Acked-by: Pravin B Shelar <pshelar@nicira.com>

Thanks.

> ---
>  net/openvswitch/vport-geneve.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/openvswitch/vport-geneve.c b/net/openvswitch/vport-geneve.c
> index 910b3ef..106a9d8 100644
> --- a/net/openvswitch/vport-geneve.c
> +++ b/net/openvswitch/vport-geneve.c
> @@ -30,7 +30,7 @@
>
>  /**
>   * struct geneve_port - Keeps track of open UDP ports
> - * @sock: The socket created for this port number.
> + * @gs: The socket created for this port number.
>   * @name: vport name.
>   */
>  struct geneve_port {
> --
> 1.9.3
>
