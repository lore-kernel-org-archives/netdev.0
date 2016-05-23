From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH 0/2 (linux-stable-4.5.y)] net: stmmac: MDIO fixes
Date: Mon, 23 May 2016 08:36:19 -0700
Message-ID: <20160523153619.GA30179@kroah.com>
References: <1464009463-23654-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: stable@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org, robin.murphy@arm.com, marc.zyngier@arm.com,
	afaerber@suse.de, bert@a20.net, linux-sunxi@googlegroups.com,
	maxime.ripard@free-electrons.com
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Return-path: <stable-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1464009463-23654-1-git-send-email-peppe.cavallaro@st.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 23, 2016 at 03:17:41PM +0200, Giuseppe Cavallaro wrote:
> These patches port some recent fixes for linux-4.5.y stable branch.
> They fix the MDIO settings trying to cover the all possible scenario
> when the stmmac is connected to a real transceiver or a switch.
> 
> These patches are needed for Kernel 4.5 where Lime2, BananaPi and Cubieboard2
> show problems when use the stmmac:
> 
> https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=823493

What are the git commit id for these patches in Linus's tree?

thanks,

greg k-h
