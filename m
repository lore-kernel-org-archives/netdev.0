From: LABBE Corentin <clabbe.montjoie@gmail.com>
Subject: Re: [PATCH] phy: remove documentation of removed member addr of
 phy_device structure
Date: Thu, 3 Mar 2016 16:46:49 +0100
Message-ID: <20160303154649.GA27779@Red>
References: <1457010748-2584-1-git-send-email-clabbe.montjoie@gmail.com>
 <20160303151419.GK15541@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160303151419.GK15541@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 03, 2016 at 04:14:19PM +0100, Andrew Lunn wrote:
> On Thu, Mar 03, 2016 at 02:12:28PM +0100, LABBE Corentin wrote:
> > Commit e5a03bfd873c ("phy: Add an mdio_device structure") removed
> > the addr member of the phy_device structure.
> > This patch remove the documentation about that member.
> > 
> > Signed-off-by: LABBE Corentin <clabbe.montjoie@gmail.com>
> 
> Hi Corentin
> 
> The patch also removed bus and dev which are documented.  Could you
> please expand you patch to remove those as well?
> 
> Thanks
> 	Andrew
> 

Yes, I will send a v2 soon.

Regards

LABBE Corentin
