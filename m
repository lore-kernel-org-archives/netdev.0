From: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH net-next V2] gro: introduce gro_mac_header_len
Date: Mon, 6 Feb 2012 19:11:10 +0200
Message-ID: <4F3009AE.2090605@mellanox.com>
References: <1328545627.2220.72.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>  <20120206.113145.1284864994961472499.davem@davemloft.net>  <1328546834.2220.79.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>  <20120206.115859.1384761795375582044.davem@davemloft.net> <1328548022.2220.87.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	<herbert-F6s6mLieUQo7FNHlEwC/lvQIK84fMopw@public.gmane.org>, <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<shlomop-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1328548022.2220.87.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 2/6/2012 7:07 PM, Eric Dumazet wrote:
> OK, I'll resend my first patch then, using hard_header_len

so, we will be back to square one... as the hard_header_len which 
advertized now by IPoIB will fail
the GRO L2 check... lets see where this discussion evolves.

Or.

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
