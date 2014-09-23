From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH] net/openvswitch: remove dup comment in vport.h
Date: Tue, 23 Sep 2014 14:44:18 -0700
Message-ID: <CALnjE+qtd_-msONSeya8CsE7KwwwtQnR66rOXF5nM-Oj+-GAkQ@mail.gmail.com>
References: <1411473735-15184-1-git-send-email-shhuiw@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>
To: Wang Sheng-Hui <shhuiw@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog112.obsmtp.com ([74.125.149.207]:44144 "HELO
	na3sys009aog112.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756108AbaIWVoS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2014 17:44:18 -0400
Received: by mail-ie0-f182.google.com with SMTP id tp5so5087098ieb.13
        for <netdev@vger.kernel.org>; Tue, 23 Sep 2014 14:44:18 -0700 (PDT)
In-Reply-To: <1411473735-15184-1-git-send-email-shhuiw@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 23, 2014 at 5:02 AM, Wang Sheng-Hui <shhuiw@gmail.com> wrote:
> Remove the duplicated comment
> "/* The following definitions are for users of the vport subsytem: */"
> in vport.h
>
> Signed-off-by: Wang Sheng-Hui <shhuiw@gmail.com>

Acked-by: Pravin B Shelar <pshelar@nicira.com>

Thanks.

> ---
>  net/openvswitch/vport.h | 1 -
>  1 file changed, 1 deletion(-)
>
> diff --git a/net/openvswitch/vport.h b/net/openvswitch/vport.h
> index 35f89d8..5b43010 100644
> --- a/net/openvswitch/vport.h
> +++ b/net/openvswitch/vport.h
> @@ -35,7 +35,6 @@ struct vport_parms;
>
>  /* The following definitions are for users of the vport subsytem: */
>
> -/* The following definitions are for users of the vport subsytem: */
>  struct vport_net {
>         struct vport __rcu *gre_vport;
>  };
> --
> 1.8.4.5
>
