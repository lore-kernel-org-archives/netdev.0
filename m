From: Greg KH <greg@kroah.com>
Subject: Re: [Kernel-janitors] Re: [PATCH 2.6.9-rc2 17/38] net/islpci_dev: replace schedule_timeout() with msleep()
Date: Fri, 1 Oct 2004 09:55:23 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041001165523.GC11646@kroah.com>
References: <5.1.0.14.2.20040924074745.00b1cd40@pop.t-online.de> <20040923221303.GB13244@us.ibm.com> <20040923221303.GB13244@us.ibm.com> <5.1.0.14.2.20040924074745.00b1cd40@pop.t-online.de> <5.1.0.14.2.20041001084419.02570b18@pop.t-online.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com,
        kernel-janitors@lists.osdl.org, mcgrof@studorgs.rutgers.edu,
        prism54-devel@prism54.org, hvr@gnu.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Margit Schubert-While <margitsw@t-online.de>
Content-Disposition: inline
In-Reply-To: <5.1.0.14.2.20041001084419.02570b18@pop.t-online.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Oct 01, 2004 at 09:04:27AM +0200, Margit Schubert-While wrote:
> At 00:15 01.10.2004 -0400, Jeff scribeth:
> >I would rather see an msleep implementation in 2.4.x...
> 
> Hear, hear.
> And can we PLEASE have a
> "#define HAVE_MSLEEP"  in delay.h ?!!!
> (2.4. AND 2.6)

No, this is not how the kernel source tree works, sorry.

greg k-h
