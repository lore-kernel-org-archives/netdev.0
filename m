From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless 2014-12-03
Date: Tue, 09 Dec 2014 13:36:02 -0500 (EST)
Message-ID: <20141209.133602.1849817956610567109.davem@davemloft.net>
References: <20141203203432.GF2896@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141203203432.GF2896@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville@tuxdriver.com>
Date: Wed, 3 Dec 2014 15:34:33 -0500

> One last(?) batch of fixes hoping to make 3.18...
> 
> In this episode, we have another trio of rtlwifi fixes
> repairing a little more damage from the major update of the
> rtlwifi-family of drivers.  These editing mistakes caused some
> memory corruption and missed a flag critical to proper interrupt
> handling.  Together, these fix the kernel regression reported at
> https://bugzilla.kernel.org/show_bug.cgi?id=88951 by Catalin Iacob.
> 
> Please let me know if there are problems!

Unfortunately, this did not make it for 3.18, but I've pulled it into my
'net' tree which I'll merge into 'net-next' for the merge window.
