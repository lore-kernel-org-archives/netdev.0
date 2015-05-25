From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH] staging: r8712u: Fix kernel warning for improper call
 of del_timer_sync()
Date: Mon, 25 May 2015 10:37:28 -0700
Message-ID: <1432575448.2846.63.camel@perches.com>
References: <1432415812-1285-1-git-send-email-Larry.Finger@lwfinger.net>
	 <CAJ=9CzbPmo+f4zjY4CqQ7TsUENpwy+zHcpxeLTbAH0DAZSkqsQ@mail.gmail.com>
	 <556268BC.5050807@lwfinger.net> <20150525091737.GQ4150@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	Haggai Eran <haggai.eran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org,
	Sudip Mukherjee <sudip-ofJRbWXBVFamYgehrs7/Lw@public.gmane.org>,
	gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Stable <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Arek Rusniak <arek.rusi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Dan Carpenter <dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150525091737.GQ4150@mwanda>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2015-05-25 at 12:17 +0300, Dan Carpenter wrote:
> These are special intern patches that
> dont' go through the normal review process.  The intern process is over
> this year.  The lack of normal review introduced a number of bugs this
> year.  I always complain to Greg about it and he says that I should join
> the intern mailing list if I care so much.

It'd be better if the approved patches from the intern list
(no idea what that is) were sent to lkml/devel@driverdev lists
for review before actually being applied.


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
