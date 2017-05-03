From: Arend van Spriel <arend.vanspriel-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH] brcmfmac: btcoex: replace init_timer with setup_timer
Date: Wed, 3 May 2017 10:05:52 +0200
Message-ID: <2f49e699-b9f7-b55f-0afc-7ac03631de28@broadcom.com>
References: <20170503073555.3922-1-cheerx1994@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        brcm80211-dev-list.pdl-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Piotr Haber <phaber-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
To: Xie Qirong <cheerx1994-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Franky Lin <franky.lin-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Hante Meuleman <hante.meuleman-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170503073555.3922-1-cheerx1994-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Content-Language: en-GB
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 5/3/2017 9:35 AM, Xie Qirong wrote:
> Signed-off-by: Xie Qirong <cheerx1994-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
> 
>   setup_timer.cocci suggested the following improvement:
>   drivers/net/wireless/broadcom/brcm80211/brcmfmac/btcoex.c:383:1-11: Use
>   setup_timer function for function on line 384.

Move the text above before your sign-off so it will end up in the git 
commit message.

When done you may also add my acknowledgement, ie.:

Acked-by: Arend van Spriel <arend.vanspriel-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>

Regards,
Arend
