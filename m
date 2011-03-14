From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [Bugme-new] [Bug 30952] New: asix driver broken since 2.6.35
Date: Mon, 14 Mar 2011 14:45:53 -0700 (PDT)
Message-ID: <20110314.144553.70194816.davem@davemloft.net>
References: <bug-30952-10286@https.bugzilla.kernel.org/>
	<20110314144309.a303662f.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	bugzilla-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org,
	bugme-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org, lipski.bogdan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20110314144309.a303662f.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Date: Mon, 14 Mar 2011 14:43:09 -0700

> 
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
> 
> The reporter says "workaround suggested in:
> https://bugzilla.kernel.org/show_bug.cgi?id=16831 seems to work well
> for me as well".  That workaround appears to be "dump the kernel driver
> and use the driver off the vendor's website".

This is an issue you've brought up to me several months ago.

I started looking into it, but because the vendor driver development
happens in a completely different universe the divergence noise is
substantial and it's a huge effort to consolidate these two drivers.

I think that until the vendor starts to care, nothing is going to
happen to resolve these ASIC driver bugs.

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
