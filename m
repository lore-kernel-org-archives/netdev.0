From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH net 0/2] netfilter: ipvs: some fixes in sctp_conn_schedule
Date: Thu, 31 Aug 2017 13:59:08 +0200
Message-ID: <20170831115904.GA16979@verge.net.au>
References: <cover.1503207076.git.lucien.xin@gmail.com>
 <20170828161732.GA13738@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Xin Long <lucien.xin@gmail.com>, netfilter-devel@vger.kernel.org,
        Alex Gartrell <agartrell@fb.com>, lvs-devel@vger.kernel.org,
        netdev@vger.kernel.org, ja@ssi.bg, wensong@linux-vs.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170828161732.GA13738@salvia>
Sender: lvs-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 28, 2017 at 06:17:32PM +0200, Pablo Neira Ayuso wrote:
> On Sun, Aug 20, 2017 at 01:38:06PM +0800, Xin Long wrote:
> > Patch 1/2 fixes the regression introduced by commit 5e26b1b3abce.
> > Patch 2/2 makes ipvs not create conn for sctp ABORT packet.
> 
> Will wait for Julian and Simon to tell me what I should do with this.

Hi Pablo,

could you take these directly with Julian's Ack and the following?

Signed-off-by: Simon Horman <horms@verge.net.au>

