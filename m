From: jaganav@us.ibm.com
Subject: Re: Linux support for RDMA (was: [Ksummit-2005-discuss] Summary of 2005 Kernel Summit Proposed Topics)
Date: Tue,  5 Apr 2005 18:19:40 -0400
Message-ID: <1112739580.42530efce23ff@imap.linux.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: Greg KH <greg@kroah.com>, Stephen Hemminger <shemminger@osdl.org>,
        Roland Dreier <roland@topspin.com>, Benjamin LaHaise <bcrl@kvack.org>,
        Dmitry Yusupov <dmitry_yus@yahoo.com>, open-iscsi@googlegroups.com,
        "David  S. Miller" <davem@davemloft.net>, mpm@selenic.com,
        andrea@suse.de, michaelc@cs.wisc.edu,
        James.Bottomley@HansenPartnership.com, ksummit-2005-discuss@thunk.org,
        netdev@oss.sgi.com, bmt@zurich.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Rik van Riel <riel@redhat.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Quoting Rik van Riel <riel@redhat.com>:

> On Sat, 2 Apr 2005 jaganav@us.ibm.com wrote:
> 
> > If this dual license is a concern to other kernel developers as well 
> > from contributing to OpenRDMA, we would seriously consider this and 
> > discuss with the adapter vendors.
> 
> It could be a problem when trying to reuse existing
> GPL code, eg. to hook into locking mechanisms.  It
> could also be a problem if you touch data structures
> that are protected by RCU.

Right, this could be one of the significant porting issues 
but it may become a real concern. Thanks.

Thanks
Venkat
