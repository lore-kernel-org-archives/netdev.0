From: Jeff Garzik <jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org>
Subject: Re: Please pull 'p54' branch of wireless-2.6
Date: Wed, 19 Sep 2007 18:01:32 -0400
Message-ID: <46F19C3C.6090605@garzik.org>
References: <20070919195527.GD5483@tuxdriver.com> <20070919210405.GA2231@infradead.org> <20070919.141200.56568833.davem@davemloft.net> <20070919212607.GA3036@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	flamingice-R9e9/4HEdknk1uMJSBkQmQ@public.gmane.org
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20070919212607.GA3036-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

John W. Linville wrote:
> On Wed, Sep 19, 2007 at 02:12:00PM -0700, David Miller wrote:
>> From: Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
>> Date: Wed, 19 Sep 2007 22:04:05 +0100
>>
>>> PLease put it into a separate subdirectory, thanks.
>>>
>>> Also net2280.h seems rather oddly named.
>> The next time I rebase I'll try to take care of this for both
>> this driver and the iwlwifi stuff.
> 
> Fine by me, although I swear I remember complaints about adding separate
> directories for drivers...*shrug*...

There were complaints about the nonsensical wireless/mac80211 directory. 
  But if there are enough files, a driver should definitely get its own 
directory.  Like life, it's a balance.  If it's just one or two C files, 
a directory might be overkill.  If it's more, it definitely warrants a 
sub-dir.

	Jeff
