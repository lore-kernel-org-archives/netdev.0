From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: Re: [target-pending 00/12] cxgb4 patch series for cxgbit.ko
Date: Tue, 15 Mar 2016 12:34:28 +0530
Message-ID: <20160315070427.GA8122@hari-Latitude-E5550>
References: <cover.1457877852.git.varun@chelsio.com>
 <1458019751.15882.31.camel@haakon3.risingtidesystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Varun Prakash <varun@chelsio.com>, target-devel@vger.kernel.org,
	netdev@vger.kernel.org, davem@davemloft.net,
	swise@opengridcomputing.com, indranil@chelsio.com, kxie@chelsio.com
To: "Nicholas A. Bellinger" <nab@linux-iscsi.org>
Return-path: <target-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1458019751.15882.31.camel@haakon3.risingtidesystems.com>
Sender: target-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 14, 2016 at 22:29:11 -0700, Nicholas A. Bellinger wrote:
> Hi Varun & Co,
> 
> On Sun, 2016-03-13 at 19:49 +0530, Varun Prakash wrote:
> > Hi Nicholas,
> > 
> >    I am posting cxgb4 patch series as
> >    suggested by you in following email thread
> > 
> >    http://www.spinics.net/lists/target-devel/msg12437.html
> > 
> >    This series consists of patches from
> >    initial cxgb4 series without any change.
> > 
> > Thanks
> > Varun
> > 
> 
> Thanks for re-posting iscsi segment offload (ISO) prerequisites as a
> stand-alone vxgb4 network driver series.
> 
> This -v1 series has been in target-pending/for-next-merge for last
> weeks, and encountered one conflict vs. net-next as reported by SFR:
> 
>   https://lkml.org/lkml/2016/2/29/34 
> 
> That said, I'm still OK to merge via target-pending to enable post v4.6
> iscsi-target developments, as long as DaveM doesn't have an objection or
> if he'd prefer to pick them up.
> 
> As-is, they still need Acked-by's from the cxgb4 driver maintainer.  
> 
> Hariprasad, please give your review + ack.
> 

The entire series looks good.

Acked-by: Hariprasad Shenai <hariprasad@chelsio.com>
