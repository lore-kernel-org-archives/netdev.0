From: Joel Becker <Joel.Becker@oracle.com>
Subject: Re: [RFC][PATCH -mm 0/9] netconsole: Multiple targets and dynamic reconfigurability
Date: Thu, 5 Jul 2007 00:04:50 -0700
Message-ID: <20070705070450.GI17650@tasint.org>
References: <20070704110739.28520.5036.sendpatchset@cselinux1.cse.iitk.ac.in> <468B8952.9030205@bx.jp.nec.com> <Pine.LNX.4.64.0707041752210.29756@cselinux1.cse.iitk.ac.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Keiichi KII <k-keiichi@bx.jp.nec.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>, Matt Mackall <mpm@selenic.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: Satyam Sharma <ssatyam@cse.iitk.ac.in>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757463AbXGEHFj@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0707041752210.29756@cselinux1.cse.iitk.ac.in>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 04, 2007 at 05:55:15PM +0530, Satyam Sharma wrote:
> On Wed, 4 Jul 2007, Keiichi KII wrote:
> > By the way, how can I add Signed-off-by:'s to your patches?
> > Should I add it to each patch and submit them to this list again?
> > 
> > Anybody could give me an advice?
> 
> I think you could just individually reply to all the mails and replace
> the "Cc:" in front of your name + email ID with "Signed-off-by:" --
> after reviewing & testing this, of course!

	If the chain is not going through Keiichi, he should be
responding with "Acked-by:", not "Signed-off-by:".  Then Satyam submits
the patches upstream with the Acked-by: line and his own Signed-off-by:

Joel

-- 

"Anything that is too stupid to be spoken is sung."  
        - Voltaire

Joel Becker
Principal Software Developer
Oracle
E-mail: joel.becker@oracle.com
Phone: (650) 506-8127
