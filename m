From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: Please pull 'b43' branch of wireless-2.6
Date: Tue, 18 Sep 2007 14:32:24 -0700 (PDT)
Message-ID: <20070918.143224.94038422.davem@davemloft.net>
References: <20070918202819.GI4940@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sam-uyr5N9Q2VtJg9hUCZPvPmw@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20070918202819.GI4940-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Date: Tue, 18 Sep 2007 16:28:19 -0400

> This series adds the b43 and b43legacy drivers, as well as the ssb
> bus infrastructure upon which they depend.
> 
> These drivers support the BCM43xx wireless hardware from Broadcom.
> The b43 driver supports modern hardware using the "version 4" firmware,
> while the b43legacy driver uses the "version 3" firmware to support
> some older devices which lack the resources to run the newer (and
> more feature rich) firmware.  Both drivers have performed well in
> -mm and Fedora rawhide, and b43 has performed well in later Fedora
> 7 kernels as well.
> 
> Furthermore, Michael and Larry have both demonstrated a strong
> commitment to the community and their users.  They both have responded
> to bugs both at the kernel.org bugzilla and in distro bugzillas.
> I have every confidence that they will continue to support their
> drivers at the same high standard that have already set.  I'd like
> to take this opportunity to thank both of them for their support both
> in the past and in the future as well.
> 
> No doubt there are still problems here.  But again, I think we would
> be better served by mainlining this code rather than continuing to
> maintain it out of stream.

John, I'm adding this and the iwlwifi bits to my net-2.6.24
tree.

Thanks.
