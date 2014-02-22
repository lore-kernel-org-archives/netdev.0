From: Andi Kleen <andi-Vw/NltI1exuRpAAqCnN02g@public.gmane.org>
Subject: Re: [PATCH] socket: Add SO_RXQ_OVFL documentation
Date: Sat, 22 Feb 2014 17:22:54 +0100
Message-ID: <20140222162253.GJ22728@two.firstfloor.org>
References: <1390911877-5984-1-git-send-email-nhorman@tuxdriver.com>
 <53086F88.5040209@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	andi-Vw/NltI1exuRpAAqCnN02g@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "Michael Kerrisk (man-pages)" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <53086F88.5040209-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> >  to bind to this port for any local address.
> >  Argument is an integer boolean flag.
> >  .TP
> > +.B SO_RXQ_OVFL
> > +Indicates that an unsigned 32 bit value ancilliary msg (cmsg) should be attached
> > +to recieved skbs indicating the number of packets dropped by the socket between

Typo s/ie/ei/

-Andi
--
To unsubscribe from this list: send the line "unsubscribe linux-man" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
