From: Dorn Hetzel <kernel@dorn.hetzel.org>
Subject: Re: r8169.c
Date: Sun, 5 Dec 2004 18:55:20 -0500
Message-ID: <20041205235519.GA21885@lilah.hetzel.org>
References: <20041119162920.GA26836@lilah.hetzel.org> <20041119201203.GA13522@electric-eye.fr.zoreil.com> <20041120003754.GA32133@lilah.hetzel.org> <20041120002946.GA18059@electric-eye.fr.zoreil.com> <20041122181307.GA3625@lilah.hetzel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
	jgarzik@pobox.com, dorn@hetzel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261411AbULEWcE@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Content-Disposition: inline
In-Reply-To: <20041122181307.GA3625@lilah.hetzel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 22, 2004 at 01:13:07PM -0500, Dorn Hetzel wrote:
> On Sat, Nov 20, 2004 at 01:29:46AM +0100, Francois Romieu wrote:
> 
> > Once you have applied one of the patch above, the patch below will improve
> > your "transmit timed out" (please apply in order and enable NAPI):
> > http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.10-rc2-mm1/r8169-250.patch
> > http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.10-rc2-mm1/r8169-255.patch
> > 
> > If things perform better you may want to use bigger frames and apply as
> > well r8169-260.patch and r8169-265.patch.
> > http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.10-rc2-mm1/r8169-260.patch
> > http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.10-rc2-mm1/r8169-265.patch
> >

I was wondering if the above 4 patches have made it into one of the
rc? releases, or at least a rc?-mm?  ?

Regards,

-Dorn
