From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: [PATCH v12 7/8] wireless: ipw2200: Replace PCI pool old API
Date: Wed, 23 Aug 2017 06:58:03 +0300
Message-ID: <87inhfx7ec.fsf@kamboji.qca.qualcomm.com>
References: <CA++WF2MAT3aHd3TYfLgym9ssFKBsti6+t9b1yJ_eXHEmRBWwcQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Romain Perier <romain.perier-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>,
        Dan Williams <dan.j.williams-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Hal Rosenstock <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Stanislav Yakovlev <stas.yakovlev-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CA++WF2MAT3aHd3TYfLgym9ssFKBsti6+t9b1yJ_eXHEmRBWwcQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
        (Stanislav Yakovlev's message of "Tue, 22 Aug 2017 18:11:14 -0400")
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

+ linux-wireless

Stanislav Yakovlev <stas.yakovlev-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:

> On 22 August 2017 at 07:47, Romain Perier <romain.perier-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org> wrote:
>> The PCI pool API is deprecated. This commit replaces the PCI pool old
>> API by the appropriate function with the DMA pool API.
>>
>> Signed-off-by: Romain Perier <romain.perier-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
>> Reviewed-by: Peter Senna Tschudin <peter.senna-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
>> ---
>>  drivers/net/wireless/intel/ipw2x00/ipw2200.c | 13 +++++++------
>>  1 file changed, 7 insertions(+), 6 deletions(-)
>>
>
> Acked-by: Stanislav Yakovlev <stas.yakovlev-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>
> Thanks, and sorry for the long review.
>
> Kalle, could you please apply it to the wireless-drivers-next tree?

It was not sent to linux-wireless so patchwork didn't see it and hence
it's not on my queue. Please resend.

[1] https://patchwork.kernel.org/project/linux-wireless/list/

-- 
Kalle Valo
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
