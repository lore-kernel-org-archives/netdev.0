From: Jean Tourrilhes <jt@bougret.hpl.hp.com>
Subject: Re: [PATCH 2.6] Intersil Prism54 wireless driver
Date: Wed, 3 Mar 2004 18:49:32 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040304024932.GA19781@bougret.hpl.hp.com>
References: <20040304023524.GA19453@bougret.hpl.hp.com> <40469683.3000609@pobox.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com,
        Linux kernel mailing list <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <40469683.3000609@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Mar 03, 2004 at 09:37:55PM -0500, Jeff Garzik wrote:
> Jean Tourrilhes wrote:
> >	Hi Dave & Jeff,
> >
> >	The attached .bz2 file is a patch for 2.6.3 adding the
> >Intersil Prism54 wireless driver. Sorry for the attachement, the file
> >is rather big, if you want inline+plaintext, I'll send that personal
> >to you.
> >	I've been using this driver with great success on 2.6.3 and
> >2.6.4-rc1 (SMP). This driver support various popular CardBus and PCI
> >802.11g cards (54 Mb/s) based on the Intersil PrismGT/PrismDuette
> >chipset.
> >	I would like this driver to go into 2.6.X. However, I
> >understand that it's lot's of code to review.
> 
> 
> I would like it to go into 2.6 too :)  I'm glad somebody submitted it.
> 
> I'll review it this weekend... and hopefully some other netdev denizens 
> will review as well and post their comments.
> 
> 	Jeff

	By the way, I should note that during my test I had
difficulties to associate with Aironet cards, but it looked like it
was a firmware related issue (firmware timing out). The rest work fine
(managed to Lucent, Ad-Hoc to another Prism54, scanning,
WE). Actually, this is the driver I used to develop ifrename.
	Have fun...

	Jean
