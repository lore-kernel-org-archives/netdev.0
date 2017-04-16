From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH nf-next] ipvs: remove unused function
 ip_vs_set_state_timeout
Date: Mon, 17 Apr 2017 07:34:59 +0900
Message-ID: <20170416223457.GA18680@verge.net.au>
References: <20170410195044.19646-1-aconole@bytheb.org>
 <20170414001309.GA28870@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Aaron Conole <aconole@bytheb.org>, netfilter-devel@vger.kernel.org,
        Wensong Zhang <wensong@linux-vs.org>,
        Julian Anastasov <ja@ssi.bg>, netdev@vger.kernel.org,
        lvs-devel@vger.kernel.org, linux-kernel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170414001309.GA28870@salvia>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On vr, apr 14, 2017 at 02:13:09 +0200, Pablo Neira Ayuso wrote:
> On Mon, Apr 10, 2017 at 03:50:44PM -0400, Aaron Conole wrote:
> > There are no in-tree callers of this function and it isn't exported.
> 
> Simon, let me know if you want to take this, or just add your
> Signed-off-by.

Hi Pablo,

I will take this.
