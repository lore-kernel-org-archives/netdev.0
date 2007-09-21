From: Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Subject: Re: [stable] [PATCH] cfg80211: fix initialisation if built-in
Date: Fri, 21 Sep 2007 15:02:53 -0700
Message-ID: <20070921220253.GA32585@kroah.com>
References: <1189424685.4506.63.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, Rob Hussey <robjhussey-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1189424685.4506.63.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 10, 2007 at 01:44:45PM +0200, Johannes Berg wrote:
> When cfg80211 is built into the kernel it needs to init earlier
> so that device registrations are run after it has initialised.
> 
> Signed-off-by: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>

When this goes into Linus's tree, please resend it to the
stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org address so we can add it to our queue.

thanks,

greg k-h
