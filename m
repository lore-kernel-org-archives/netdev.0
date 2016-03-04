From: "Valo, Kalle" <kvalo-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
Subject: Re: [PATCH] ath10k: remove impossible code
Date: Fri, 4 Mar 2016 08:39:49 +0000
Message-ID: <87io12zlf4.fsf@kamboji.qca.qualcomm.com>
References: <1454397280-4758-1-git-send-email-sudipm.mukherjee@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"ath10k-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org" <ath10k-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
To: Sudip Mukherjee <sudipm.mukherjee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1454397280-4758-1-git-send-email-sudipm.mukherjee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
	(Sudip Mukherjee's message of "Tue, 2 Feb 2016 12:44:40 +0530")
Content-Language: en-US
Content-ID: <4CCDF84B67B45B479043DACFA2D090AF-zC7DfRvBq/JWk0Htik3J/w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Sudip Mukherjee <sudipm.mukherjee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:

> From: Sudip Mukherjee <sudip-ofJRbWXBVFamYgehrs7/Lw@public.gmane.org>
>
> len has been initialized with a value of 0 and buf_len with 4096. There
> is no way that this condition (len > buf_len) can be true now.
>
> Signed-off-by: Sudip Mukherjee <sudip-ofJRbWXBVFamYgehrs7/Lw@public.gmane.org>

Applied, thanks.

-- 
Kalle Valo--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
