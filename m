From: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH RESEND net-next] bluetooth: hci_core: Replace
 list_for_each with list_for_each_entry() helper
Date: Mon, 22 Oct 2012 10:00:43 -0700
Message-ID: <1350925243.1785.24.camel@aeonflux>
References: <1350912121-24171-1-git-send-email-kirjanov@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Denis Kirjanov <kirjanov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1350912121-24171-1-git-send-email-kirjanov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Denis,

> Replace list_for_each with list_for_each_entry() helper
> 
> Signed-off-by: Denis Kirjanov <kirjanov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
>  include/net/bluetooth/hci_core.h |   20 ++++++++------------
>  1 files changed, 8 insertions(+), 12 deletions(-)

Acked-by: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>

Regards

Marcel
