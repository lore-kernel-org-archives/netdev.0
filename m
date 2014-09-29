From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: 3.17-rc1 oops during network interface configuration
Date: Mon, 29 Sep 2014 12:00:17 -0700
Message-ID: <1412017217.30721.38.camel@edumazet-glaptop2.roam.corp.google.com>
References: <53F1EF18.7010909@acm.org> <53F47917.8080003@mellanox.com>
	 <F580F466-28A5-4BDD-A338-D5C065A760C1@oracle.com>
	 <541000F1.5000805@mellanox.com>
	 <6C43129E-4365-4BEF-ADAD-963B8F386789@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Govindarajulu Varadarajan <_govind-KK0ffGbhmjU@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	LKML Kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-rdma <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Bart Van Assche <bvanassche-HInyCGIudOg@public.gmane.org>,
	Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Tal Alon <talal-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yevgeny Petrilin <yevgenyp-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
To: Chuck Lever <chuck.lever-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <6C43129E-4365-4BEF-ADAD-963B8F386789-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2014-09-29 at 14:52 -0400, Chuck Lever wrote:

> Is there a bugzilla report filed for this issue? Has there been any progress
> towards a fix?

This is fixed in Linus tree.

http://git.kernel.org/cgit/linux/kernel/git/davem/net.git/commit/?id=257117862634d89de33fec74858b1a0ba5ab444b

http://git.kernel.org/cgit/linux/kernel/git/davem/net.git/commit/?id=b49fe36208b45f76dfbcfcd3afd952a33fa9f5ce


--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
