From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless 2014-03-14
Date: Fri, 14 Mar 2014 22:51:47 -0400 (EDT)
Message-ID: <20140314.225147.855002342224224013.davem@davemloft.net>
References: <20140314182024.GA20339@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140314182024.GA20339@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville@tuxdriver.com>
Date: Fri, 14 Mar 2014 14:20:26 -0400

> Please pull these last(?) few wireless bits intended for the 3.14
> stream.  Each is here to address a problem found with a patch already
> merged...
> 
> Dave Jones gives us a memory leak fix, for an error path in brcmfmac.
> 
> Felix Fietkau moves a small delay to make it actually reachable.
> 
> Helmut Schaa fixes an ath9k sequence numbering problem for non-data
> frames.
> 
> Stanislaw Gruszka reverts an earlier fix that was found to cause
> random connection drops on RT5390 PCI adapters
> 
> Please let me know if there are problems!  I'll be back from watching
> the Veronica Mars movie by about 9pm... :-)

:-)

Pulled, thanks John.
