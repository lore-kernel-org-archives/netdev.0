From: Satyam Sharma <ssatyam@cse.iitk.ac.in>
Subject: Re: [PATCH -mm 8/9] netconsole: Update documentation for dynamic
 reconfigurability
Date: Thu, 5 Jul 2007 15:08:11 +0530 (IST)
Message-ID: <Pine.LNX.4.64.0707051506080.15925@cselinux1.cse.iitk.ac.in>
References: <20070704110739.28520.5036.sendpatchset@cselinux1.cse.iitk.ac.in>
 <20070704110819.28520.50445.sendpatchset@cselinux1.cse.iitk.ac.in>
 <20070705065213.GH17650@tasint.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Keiichi Kii <k-keiichi@bx.jp.nec.com>,
	Netdev <netdev@vger.kernel.org>, Matt Mackall <mpm@selenic.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: Joel Becker <Joel.Becker@oracle.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760854AbXGEJQz@vger.kernel.org>
In-Reply-To: <20070705065213.GH17650@tasint.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 4 Jul 2007, Joel Becker wrote:
> On Wed, Jul 04, 2007 at 04:38:19PM +0530, Satyam Sharma wrote:
> > +Some examples follow (configfs is mounted at the /config mountpoint, say).
> 
> 	configfs is generally expected to be mounted at
> /sys/kernel/config, and it even creates that mountpoint for itself.  The
> documentation should probably be consistent with that.

Ok, will do that in the next iteration -- I'll wait for a couple more
days for comments from others, and then post the v2 patches sometime
during the weekend.

Satyam
