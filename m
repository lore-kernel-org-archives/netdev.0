From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v3 1/2] udp_tunnel: Remove redundant
 udp_tunnel_gro_complete().
Date: Fri, 06 May 2016 18:25:38 -0400 (EDT)
Message-ID: <20160506.182538.1303822671942963507.davem@davemloft.net>
References: <1462317021-7236-1-git-send-email-jarno@ovn.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jesse@kernel.org
To: jarno@ovn.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1462317021-7236-1-git-send-email-jarno@ovn.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jarno Rajahalme <jarno@ovn.org>
Date: Tue,  3 May 2016 16:10:20 -0700

> The setting of the UDP tunnel GSO type is already performed by
> udp[46]_gro_complete().
> 
> Signed-off-by: Jarno Rajahalme <jarno@ovn.org>

Applied.
