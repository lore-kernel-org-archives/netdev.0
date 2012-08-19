From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: IPv4 BUG: held lock freed!
Date: Sun, 19 Aug 2012 21:04:41 +0800
Message-ID: <20120819130441.GA22845@localhost>
References: <20120818021918.GA6499@localhost>
 <1345380682.5158.201.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	networking <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1345380682.5158.201.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Could you test following patch ?

Yes, sure. Thanks for the quick fix!  I should have reported it earlier
(so as to get it fixed earlier) once find the bisect will be time consuming..

Please be patient -- it will take 1-2 days to confirm the bug fix.

Thanks,
Fengguang
