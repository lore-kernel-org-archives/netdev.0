From: Greg KH <greg@kroah.com>
Subject: Re: Linux support for RDMA (was: [Ksummit-2005-discuss] Summary of 2005 Kernel Summit Proposed Topics)
Date: Fri, 1 Apr 2005 21:27:38 -0800
Message-ID: <20050402052738.GA17506@kroah.com>
References: <20050401154348.553f3c46@dxpl.pdx.osdl.net> <1112405833.424df749e61b5@imap.linux.ibm.com>
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
In-Reply-To: <1112405833.424df749e61b5@imap.linux.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Apr 01, 2005 at 08:37:13PM -0500, jaganav@us.ibm.com wrote:
> 
> Several RNIC adapter vendors, who contribute to the 
> openRDMA effort, are quite willing to opensource 
> their drivers through openRDMA project.

"Several"?  Why not all?

And why the dual license?  What good is writing Linux kernel code that
is BSD licensed for such a core component?  Didn't you all learn from
the openib licensing mess?

thanks,

greg k-h
