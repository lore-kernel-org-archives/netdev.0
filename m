From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: pull request: wireless-next 2014-10-03
Date: Tue, 7 Oct 2014 10:18:44 -0400
Message-ID: <20141007141844.GH25590@tuxdriver.com>
References: <20141003180151.GE27414@tuxdriver.com>
 <20141005.213511.339356320070784471.davem@davemloft.net>
 <20141005.213853.488066614144870837.davem@davemloft.net>
 <20141007.004724.187788111776188480.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, larry.finger@lwfinger.net
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141007.004724.187788111776188480.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 07, 2014 at 12:47:24AM -0400, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Sun, 05 Oct 2014 21:38:53 -0400 (EDT)
> 
> > From: David Miller <davem@davemloft.net>
> > Date: Sun, 05 Oct 2014 21:35:11 -0400 (EDT)
> > 
> >> From: "John W. Linville" <linville@tuxdriver.com>
> >> Date: Fri, 3 Oct 2014 14:01:52 -0400
> >> 
> >>> Please pull tihs batch of updates intended for the 3.18 stream!
> >> 
> >> Pulled, thanks for the stellar pull request text, as always.
> > 
> > John, what's the deal with the following?  Will it be resolved by the
> > driver being removed from the staging tree?
> > 
> > WARNING: drivers/staging/rtl8192ee/r8192ee: 'rtl_evm_dbm_jaguar' exported twice. Previous export was in drivers/net/wireless/rtlwifi/rtlwifi.ko
> 
> John, ping?

Sorry, Dave -- sendmail died on my local machine and I didn't notice
until now... :-(

Anyway...yes, the staging driver should be removed by a patch in
Greg's queue.

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
