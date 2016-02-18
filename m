From: Robert Richter <robert.richter@caviumnetworks.com>
Subject: Re: [PATCH 2/2] net, thunderx: Use bool in structs where possible
Date: Thu, 18 Feb 2016 17:42:17 +0100
Message-ID: <20160218164217.GP24726@rric.localdomain>
References: <1455799149-19590-1-git-send-email-rrichter@caviumnetworks.com>
 <1455799149-19590-3-git-send-email-rrichter@caviumnetworks.com>
 <20160218.110514.652169911099659792.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <sgoutham@cavium.com>, <rric@kernel.org>, <netdev@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160218.110514.652169911099659792.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 18.02.16 11:05:14, David Miller wrote:
> From: Robert Richter <rrichter@caviumnetworks.com>
> Date: Thu, 18 Feb 2016 13:39:09 +0100
> 
> > From: Robert Richter <rrichter@cavium.com>
> > 
> > Looks like the :1 notation was accidentally introduced (this still
> > uses 1 byte per flag). Using bool instead, which is the common use.
> > 
> > Signed-off-by: Robert Richter <rrichter@cavium.com>
> 
> Such cleanups are not appropriate for 'net'.  Only real bug fixes should
> be targetted that.
> 
> Respin these patches targetting the correct tree(s).

Do you mean posting the two as "trivial" patches?

Thanks,

-Robert
