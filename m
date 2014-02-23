From: "Michael Kerrisk (man-pages)" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] socket: Add SO_RXQ_OVFL documentation
Date: Sun, 23 Feb 2014 08:51:37 +0100
Message-ID: <CAKgNAkjes8xEBkT6BoGtb_F8tg4UTS=_KNKoGYbZh2X=aXr9Jw@mail.gmail.com>
References: <1390911877-5984-1-git-send-email-nhorman@tuxdriver.com>
 <53086F88.5040209@gmail.com> <20140222162253.GJ22728@two.firstfloor.org>
Reply-To: mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-man <linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Andi Kleen <andi-Vw/NltI1exuRpAAqCnN02g@public.gmane.org>
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20140222162253.GJ22728-1g7Xle2YJi4/4alezvVtWx2eb7JE58TQ@public.gmane.org>
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Feb 22, 2014 at 5:22 PM, Andi Kleen <andi-Vw/NltI1exuRpAAqCnN02g@public.gmane.org> wrote:
>> >  to bind to this port for any local address.
>> >  Argument is an integer boolean flag.
>> >  .TP
>> > +.B SO_RXQ_OVFL
>> > +Indicates that an unsigned 32 bit value ancilliary msg (cmsg) should be attached
>> > +to recieved skbs indicating the number of packets dropped by the socket between
>
> Typo s/ie/ei/

Hi Andi.

Thanks -- I should have said that I (already) spotted and fixed that.

Cheers,

Michael

-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/
--
To unsubscribe from this list: send the line "unsubscribe linux-man" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
