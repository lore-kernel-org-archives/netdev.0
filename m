From: Greg KH <greg@kroah.com>
Subject: Re: Linux support for RDMA (was: [Ksummit-2005-discuss] Summary of 2005 Kernel Summit Proposed Topics)
Date: Fri, 1 Apr 2005 22:02:16 -0800
Message-ID: <20050402060216.GA17766@kroah.com>
References: <20050401154348.553f3c46@dxpl.pdx.osdl.net> <1112405833.424df749e61b5@imap.linux.ibm.com> <20050402052738.GA17506@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>,
        Roland Dreier <roland@topspin.com>, Benjamin LaHaise <bcrl@kvack.org>,
        Dmitry Yusupov <dmitry_yus@yahoo.com>, open-iscsi@googlegroups.com,
        "David  S. Miller" <davem@davemloft.net>, mpm@selenic.com,
        andrea@suse.de, michaelc@cs.wisc.edu,
        James.Bottomley@HansenPartnership.com, ksummit-2005-discuss@thunk.org,
        netdev@oss.sgi.com, bmt@zurich.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jaganav@us.ibm.com
Content-Disposition: inline
In-Reply-To: <20050402052738.GA17506@kroah.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Apr 01, 2005 at 09:27:38PM -0800, Greg KH wrote:
> On Fri, Apr 01, 2005 at 08:37:13PM -0500, jaganav@us.ibm.com wrote:
> > 
> > Several RNIC adapter vendors, who contribute to the 
> > openRDMA effort, are quite willing to opensource 
> > their drivers through openRDMA project.
> 
> "Several"?  Why not all?
> 
> And why the dual license?  What good is writing Linux kernel code that
> is BSD licensed for such a core component?  Didn't you all learn from
> the openib licensing mess?

Oh, and for those of you who might not know what mess I am talking
about:

The openib code was set up to be dual GPL and BSD licensed for the
express purpose of taking the openib code and placing it into a closed
source operating system (not any of the *BSDs).  Needless to say, this
has prevented me from doing any openib work, and probably the same for a
number of other Linux kernel developers.

If you all wish to duplicate this stupidity, feel free, but do not
expect to get any help from the community...

thanks,

greg k-h
