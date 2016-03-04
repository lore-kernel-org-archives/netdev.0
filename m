From: "Valo, Kalle" <kvalo-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
Subject: Re: [PATCH] ath10k: fix erroneous return value
Date: Fri, 4 Mar 2016 08:41:15 +0000
Message-ID: <8760x2zlcn.fsf@kamboji.qca.qualcomm.com>
References: <1455123535-26751-1-git-send-email-a.s.protopopov@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"ath10k-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org" <ath10k-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
To: Anton Protopopov <a.s.protopopov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1455123535-26751-1-git-send-email-a.s.protopopov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
	(Anton Protopopov's message of "Wed, 10 Feb 2016 11:58:55 -0500")
Content-Language: en-US
Content-ID: <79582C88FC1A8E4296C2A2DC849892A6-zC7DfRvBq/JWk0Htik3J/w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Anton Protopopov <a.s.protopopov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:

> The ath10k_pci_hif_exchange_bmi_msg() function may return the positive
> value EIO instead of -EIO in case of error.
>
> Signed-off-by: Anton Protopopov <a.s.protopopov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

Applied, thanks.

-- 
Kalle Valo--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
