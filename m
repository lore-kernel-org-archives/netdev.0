From: jaganav@us.ibm.com
Subject: Re: Linux support for RDMA (was: [Ksummit-2005-discuss] Summary of 2005 Kernel Summit Proposed Topics)
Date: Thu, 31 Mar 2005 21:13:39 -0500
Message-ID: <1112321619.424cae539e75e@imap.linux.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: Benjamin LaHaise <bcrl@kvack.org>, Dmitry Yusupov <dmitry_yus@yahoo.com>,
        open-iscsi@googlegroups.com, "David S. Miller" <davem@davemloft.net>,
        mpm@selenic.com, andrea@suse.de, michaelc@cs.wisc.edu,
        James.Bottomley@HansenPartnership.com, ksummit-2005-discuss@thunk.org,
        netdev@oss.sgi.com, bmt@zurich.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Roland Dreier <roland@topspin.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Quoting Roland Dreier <roland@topspin.com>:
> I have to admit I don't know much about the TOE / RDMA/TCP / RNIC (or
> whatever you want to call it) world.  However I know that the large
> majority of InfiniBand use right now is running on Linux, and I hope
> the Linux community is willing to work with the IB community.
>

Just want to let everyone know know that we have started an opensource
effort (www.openrdma.org) for enablement of RNICs (RDMA enabled NICs). This
community has now come up with an architecture
(http://rdma.sourceforge.net/architecture.pdf) to build this support in Linux.
Would really appreciate if you review and provide any comments. We have just
started to hack but no code is available on this project yet.

Thanks
Venkat
