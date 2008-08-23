From: Divy Le Ray <divy@chelsio.com>
Subject: Re: [PATCH 4/4 2.6.28] cxgb3i - cxgb3i iscsi driver
Date: Sat, 23 Aug 2008 12:31:38 -0700
Message-ID: <200808231231.40751.divy@chelsio.com>
References: <200808221840.m7MIeuvB004442@localhost.localdomain> <20080822124844.b05ee3e8.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "Karen Xie" <kxie@chelsio.com>, netdev@vger.kernel.org,
	open-iscsi@googlegroups.com, linux-scsi@vger.kernel.org,
	linux-kernel@vger.kernel.org, jgarzik@pobox.com,
	davem@davemloft.net, michaelc@cs.wisc.edu,
	"Steve Wise" <swise@opengridcomputing.com>, rdreier@cisco.com,
	daisyc@us.ibm.com, wenxiong@us.ibm.com, bhua@us.ibm.com,
	"Dimitrios Michailidis" <dm@chelsio.com>,
	"Casey Leedom" <leedom@chelsio.com>
To: "Andrew Morton" <akpm@linux-foundation.org>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20080822124844.b05ee3e8.akpm@linux-foundation.org>
Content-Disposition: inline
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 22 August 2008 12:48:44 pm Andrew Morton wrote:
> On Fri, 22 Aug 2008 11:40:56 -0700
>
> Karen Xie <kxie@chelsio.com> wrote:
> > [PATCH 4/4 2.6.28] cxgb3i - cxgb3i iscsi driver
> >
> > From: Karen Xie <kxie@chelsio.com>
> >
> > cxgb3i iSCSI driver.
> >
> > Signed-off-by: Karen Xie <kxie@chelsio.com>
>
> I'm going to suggest that this not be merged in this form due to the
> __GFP_NOFAIL issues identified below.
>

Hi Andrew,

thanks for the review. We've started fixing the obvious and looking at 
alternatives for the nofail allocations.

Cheers,
Divy
