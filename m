From: Allen <allen.pais-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] [net-next]NFC: Convert timers to use timer_setup()
Date: Thu, 12 Oct 2017 01:22:31 +0530
Message-ID: <59DE767F.2020304@oracle.com>
References: <1507718024-2134-1-git-send-email-allen.pais@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1507718024-2134-1-git-send-email-allen.pais-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> Switch to using the new timer_setup() and from_timer()
> for net/nfc/*
>
> Signed-off-by: Allen Pais <allen.pais-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
> ---
> ---
>   net/nfc/core.c          |  8 +++-----
>   net/nfc/hci/core.c      |  7 +++----
>   net/nfc/hci/llc_shdlc.c | 23 +++++++++--------------
>   net/nfc/llcp_core.c     | 14 ++++++--------
>   4 files changed, 21 insertions(+), 31 deletions(-)
>

  My bad, I missed the Reviewed-by.

Reviewed-by: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>

- Allen
