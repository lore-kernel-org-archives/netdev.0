From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: Linux support for RDMA (was: [Ksummit-2005-discuss] Summary of 2005 Kernel Summit Proposed Topics)
Date: Sat, 2 Apr 2005 17:01:17 +0200
Message-ID: <20050402150116.GU29492@g5.random>
References: <20050401154348.553f3c46@dxpl.pdx.osdl.net> <1112405833.424df749e61b5@imap.linux.ibm.com> <20050402052738.GA17506@kroah.com> <20050402060216.GA17766@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jaganav@us.ibm.com, Stephen Hemminger <shemminger@osdl.org>,
        Roland Dreier <roland@topspin.com>, Benjamin LaHaise <bcrl@kvack.org>,
        Dmitry Yusupov <dmitry_yus@yahoo.com>, open-iscsi@googlegroups.com,
        "David  S. Miller" <davem@davemloft.net>, mpm@selenic.com,
        michaelc@cs.wisc.edu, James.Bottomley@HansenPartnership.com,
        ksummit-2005-discuss@thunk.org, netdev@oss.sgi.com, bmt@zurich.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Greg KH <greg@kroah.com>
Content-Disposition: inline
In-Reply-To: <20050402060216.GA17766@kroah.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Apr 01, 2005 at 10:02:16PM -0800, Greg KH wrote:
> If you all wish to duplicate this stupidity, feel free, but do not
> expect to get any help from the community...

And just in case: do not expect to be allowed to use stuff like the
rbtree.[ch] which is GPL'd (not LGPL). (ib patches from topspin
originally relicensed rbtree.[ch] under BSD...)
