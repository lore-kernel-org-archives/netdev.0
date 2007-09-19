From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: Please pull 'iwlwifi' branch of wireless-2.6
Date: Wed, 19 Sep 2007 10:57:50 -0400
Message-ID: <20070919145749.GA5483@tuxdriver.com>
References: <20070918185040.GF4940@tuxdriver.com> <20070918.122258.82101397.davem@davemloft.net> <46F12414.8000900@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jeff Garzik <jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <46F12414.8000900-o2qLIJkoznsdnm+yROfE0A@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 19, 2007 at 09:28:52AM -0400, Jeff Garzik wrote:
> David Miller wrote:
> >Jeff, if you have no objections I'll pull this into net-2.6.24

> Given that there is now a large backlog of new drivers to review, I 
> think the preferred course of action would be to queue them into -mm 
> (via net-2.6.24) for wider review and testing, and then make sure they 
> all get a thorough review+ACK before pushing upstream.

FWIW, all of the wireless drivers posted recently have been in -mm
for some time thanks to Andrew's pulls of wireless-dev.

> So far, its sounding like each review has turned up stuff that wants 
> fixing before the drivers commented upon go upstream.

I'm sure there are things worth fixing.  Feel free to comment and
I/we will scramble to make the appropriate changes.

John
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
