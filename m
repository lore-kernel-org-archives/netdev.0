From: Petko Manolov <petkan@mip-labs.com>
Subject: Re: [PATCH 1/1] net: pegasus: remove dead coding
Date: Fri, 20 May 2016 10:33:47 +0300
Message-ID: <20160520073347.GH21813@p310>
References: <1463530410-12772-1-git-send-email-xypron.glpk@gmx.de>
 <20160519.113542.960620764938295044.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: xypron.glpk@gmx.de, petkan@nucleusys.com,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160519.113542.960620764938295044.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 16-05-19 11:35:42, David Miller wrote:
> From: Heinrich Schuchardt <xypron.glpk@gmx.de>
> Date: Wed, 18 May 2016 02:13:30 +0200
> 
> > (!count || count < 4) is always true.
> > So let's remove the coding which is dead at least since 2005.
> > 
> > Signed-off-by: Heinrich Schuchardt <xypron.glpk@gmx.de>
> 
> Applied.

David, the patch you applied is broken.  It seems that you didn't follow the 
discussion from the past couple of days.  Please revert it.


		Petko
