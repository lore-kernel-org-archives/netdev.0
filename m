From: Jeff Garzik <jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org>
Subject: Re: Please pull 'iwlwifi' branch of wireless-2.6
Date: Wed, 19 Sep 2007 09:28:52 -0400
Message-ID: <46F12414.8000900@garzik.org>
References: <20070918185040.GF4940@tuxdriver.com> <20070918.122258.82101397.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20070918.122258.82101397.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> Jeff, if you have no objections I'll pull this into net-2.6.24


Given that there is now a large backlog of new drivers to review, I 
think the preferred course of action would be to queue them into -mm 
(via net-2.6.24) for wider review and testing, and then make sure they 
all get a thorough review+ACK before pushing upstream.

So far, its sounding like each review has turned up stuff that wants 
fixing before the drivers commented upon go upstream.

	Jeff
