From: James Ketrenos <jketreno-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Subject: Re: warnings in git-wireless
Date: Tue, 05 Jun 2007 13:12:03 -0700
Message-ID: <4665C393.2000507@linux.intel.com>
References: <20070605020614.3f06b2ab.akpm@linux-foundation.org> <20070605115701.GA5391@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20070605115701.GA5391-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

John W. Linville wrote:
> On Tue, Jun 05, 2007 at 02:06:14AM -0700, Andrew Morton wrote:
> 
>> Please, don't anybody dare think about thinking about letting this anywhere
>> near mainline until it has had a thorough review.  Or at least, a little bit
>> of review.
> 
> Don't worry -- I assure you that everyone is aware of the issues.
> 
> John

Yes, we certainly don't want a driver to be "near mainline" that does things that the rest of the kernel and other drivers are doing.  We should force them to stay out-of-tree until any and everything is resolved.  Heaven forbid that the code should be merged, contributed, and improved upon as a community.

You'd think these guys were trying to enable folks with a driver so they can use the hardware they bought or something.  Its almost laughable.  What idiots.

James
