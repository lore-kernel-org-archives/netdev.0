From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: Please pull 'iwlwifi' branch of wireless-2.6
Date: Tue, 18 Sep 2007 12:22:58 -0700 (PDT)
Message-ID: <20070918.122258.82101397.davem@davemloft.net>
References: <20070918185040.GF4940@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20070918185040.GF4940-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Date: Tue, 18 Sep 2007 14:50:40 -0400

> Jeff & Dave,
> 
> Here it is -- it's big, it's...well...beautiful in its own way...well,
> at least it seems to work... :-)
> 
> There are some outstanding issues.  The driver does more than it
> probably should under the covers instead of in the stack, and the
> issue of including headers with a "../../mac80211/..." path remains.
> Still, I think it would be better to get this mainlined than to keep
> it out of stream.

Jeff, if you have no objections I'll pull this into net-2.6.24

Thanks.
