From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv4: flush route cache after change accept_local
Date: Thu, 01 Dec 2011 12:52:00 -0500 (EST)
Message-ID: <20111201.125200.1219939487021672308.davem@davemloft.net>
References: <1e224b52de77dcd5f994c8e4c77c780c6996e4a4.1322740026.git.panweiping3@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: panweiping3@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1e224b52de77dcd5f994c8e4c77c780c6996e4a4.1322740026.git.panweiping3@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Weiping Pan <panweiping3@gmail.com>
Date: Thu,  1 Dec 2011 19:47:56 +0800

> +		if ((i == IPV4_DEVCONF_ACCEPT_LOCAL - 1))

I don't think the extra parenthesis is appropriate here, please only use
one set of them.

Thanks.
