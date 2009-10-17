From: David Miller <davem@davemloft.net>
Subject: Re: [Pv-drivers] [PATCH -next] vmxnet3: use dev_dbg, fix build for
 CONFIG_BLOCK=n
Date: Fri, 16 Oct 2009 17:54:13 -0700 (PDT)
Message-ID: <20091016.175413.236830274.davem@davemloft.net>
References: <20091015152538.74a1cb15.sfr@canb.auug.org.au>
	<4AD7A24F.6000900@oracle.com>
	<8B1F619C9F5F454E81D90D3C161698D7017DD56435@EXCH-MBX-3.vmware.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: randy.dunlap@oracle.com, sfr@canb.auug.org.au,
	pv-drivers@vmware.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-next@vger.kernel.org
To: bhavesh@vmware.com
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <8B1F619C9F5F454E81D90D3C161698D7017DD56435@EXCH-MBX-3.vmware.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bhavesh Davda <bhavesh@vmware.com>
Date: Thu, 15 Oct 2009 15:35:02 -0700

> Who ever compiles with CONFIG_BLOCK=n? Just kidding...

Who ever uses block layer debugging facilities in a networking
driver?

> Thanks again for making this change! Ship it!
> 
> Signed-off-by: Bhavesh Davda <bhavesh@vmware.com>

Applied, thanks everyone.
