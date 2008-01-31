From: Jeff Garzik <jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org>
Subject: Re: net-2.6.25 is no more...
Date: Thu, 31 Jan 2008 01:09:21 -0500
Message-ID: <47A16611.3000602@garzik.org>
References: <20080129.212216.186173371.davem@davemloft.net>	<47A03D4D.5090301@fr.ibm.com> <20080130.054807.182676684.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080130.054807.182676684.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
> Date: Wed, 30 Jan 2008 10:03:09 +0100
> 
>> David Miller wrote:
>>> Now that the bulk has been merged over and we are
>>> actively working alongside Linus's tree I have moved
>>> all current patch applying to net-2.6 instead of net-2.6.25,
>>> so the current tree to use is:
>>>
>>> 	kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git
>> This tree is for fixes only, right ? or shall we send enhancement 
>> patches to net-2.6 until net-2.6.26 appears ?
> 
> The latter.

So...  what to do about changes which are not bug fixes?  Such changes 
should not go upstream immediately, because that's the standard rule for 
merge windows.

And queueing them on our side just re-creates the same old situation we 
just changed away from, after all.

	Jeff
