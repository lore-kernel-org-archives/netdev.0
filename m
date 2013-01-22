From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] xen-netback: allow changing the MAC address of the
 interface
Date: Tue, 22 Jan 2013 15:29:37 -0500 (EST)
Message-ID: <20130122.152937.698328122484839991.davem@davemloft.net>
References: <1358878105-7890-1-git-send-email-msw@amazon.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, ian.campbell@citrix.com,
	netdev@vger.kernel.org, xen-devel@lists.xen.org,
	konrad.wilk@oracle.com
To: msw@amazon.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1358878105-7890-1-git-send-email-msw@amazon.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Matt Wilson <msw@amazon.com>
Date: Tue, 22 Jan 2013 18:08:25 +0000

> Sometimes it is useful to be able to change the MAC address of the
> interface for netback devices. For example, when using ebtables it may
> be useful to be able to distinguish traffic from different interfaces
> without depending on the interface name.
> 
> Reported-by: Nikita Borzykh <sample.n@gmail.com>
> Reported-by: Paul Harvey <stockingpaul@hotmail.com>
> Cc: netdev@vger.kernel.org
> Cc: xen-devel@lists.xen.org
> Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
> Acked-by: Ian Campbell <ian.campbell@citrix.com>
> Signed-off-by: Matt Wilson <msw@amazon.com>

Applied to net-next, thanks.
