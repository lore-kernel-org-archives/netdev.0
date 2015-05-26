From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH] staging: r8712u: Fix kernel warning for improper call
 of del_timer_sync()
Date: Mon, 25 May 2015 21:55:08 -0700
Message-ID: <1432616108.2846.83.camel@perches.com>
References: <1432415812-1285-1-git-send-email-Larry.Finger@lwfinger.net>
	 <CAJ=9CzbPmo+f4zjY4CqQ7TsUENpwy+zHcpxeLTbAH0DAZSkqsQ@mail.gmail.com>
	 <556268BC.5050807@lwfinger.net> <20150525091737.GQ4150@mwanda>
	 <1432575448.2846.63.camel@perches.com> <20150526044611.GA3465@sudip-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Dan Carpenter <dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
	devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org,
	Sudip Mukherjee <sudip-ofJRbWXBVFamYgehrs7/Lw@public.gmane.org>,
	gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Stable <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Haggai Eran <haggai.eran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Arek Rusniak <arek.rusi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
To: Sudip Mukherjee <sudipm.mukherjee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150526044611.GA3465@sudip-PC>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-05-26 at 10:16 +0530, Sudip Mukherjee wrote:
> On Mon, May 25, 2015 at 10:37:28AM -0700, Joe Perches wrote:
> > It'd be better if the approved patches from the intern list
> > (no idea what that is) were sent to lkml/devel@driverdev lists
> > for review before actually being applied.
> Its the outreachy program. And http://kernelnewbies.org/OutreachyApply
> mentions specifically: "email your first patch to the outreachy-kernel
> mailing list. Do not send patches to the tmain Linux mailing lists"

The same thing happens with the eudyptula patches.

That doesn't at all make applying those novice patches
without review by a more widely read list any more sensible.


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
