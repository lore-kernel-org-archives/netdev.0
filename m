From: Jack Morgenstein <jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Subject: Re: [PATCH V2 1/9] net/mlx5: Mellanox Connect-IB, core driver part 1/3
Date: Thu, 4 Jul 2013 17:55:45 +0300
Message-ID: <201307041755.45727.jackm@dev.mellanox.co.il>
References: <1372871592-32033-1-git-send-email-ogerlitz@mellanox.com> <201307041626.45125.jackm@dev.mellanox.co.il> <1372947461.1886.28.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, eli-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org, moshel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
	Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1372947461.1886.28.camel@joe-AO722>
Content-Disposition: inline
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thursday 04 July 2013 17:17, Joe Perches wrote:
> Not the vertical spacing, the newline inside the quotes.
> ie: "unknown status code\n" should be "unknown status code"
> 
You're right!  I misunderstood, and did not notice the newline char.
Good catch!

While I was at it, though, I eliminated the blank lines between
the cases/default -- fewer lines in the file, and readable enough
this way.

Thanks!
-Jack
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
