From: Dan Carpenter <dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH resend] rsi: Fix a potential memory leak in
 rsi_set_channel()
Date: Thu, 10 Apr 2014 23:07:22 +0300
Message-ID: <20140410200722.GN4963@mwanda>
References: <20140410203146.767149e7@spike>
 <CAJUuVQ5KW3v0DgwotDMow=rBvxoZKfYYD2misXbsMD6c1UaShw@mail.gmail.com>
 <20140410195402.GA17308@kroah.com>
 <CAJUuVQ7xgRLDzwojDCdb3yhTm3HygypMLXyaRiErnVveNVz+sQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg Kroah-Hartman <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>,
	Christian Engelmayer <cengelma-RbZlAiThDcE@public.gmane.org>, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
	fariyaf-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Andev <debiandev-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAJUuVQ7xgRLDzwojDCdb3yhTm3HygypMLXyaRiErnVveNVz+sQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 10, 2014 at 04:01:35PM -0400, Andev wrote:
> On Thu, Apr 10, 2014 at 3:54 PM, Greg Kroah-Hartman <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org> wrote:
> > On Thu, Apr 10, 2014 at 03:46:12PM -0400, Andev wrote:
> >> Adding Greg KH,
> >
> > Why do I care about this?
> >
> 
> I am not sure if this needs to be applied to stable too. Should I have
> cc'ed stable@?

Read Documentation/stable_kernel_rules.txt.

But for netdev, then Dave M. maintains a queue of patches which go to
stable.  So this would go through Dave's stable queue and he forwards
them to Greg.

regards,
dan carpenter

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
