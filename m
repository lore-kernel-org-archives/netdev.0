From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH nf-next] ip_vs_sync: change comparison on
 sync_refresh_period
Date: Thu, 13 Apr 2017 07:48:08 +0900
Message-ID: <20170412224808.GB7620@verge.net.au>
References: <20170412203812.15091-1-aconole@bytheb.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Wensong Zhang <wensong@linux-vs.org>,
        Julian Anastasov <ja@ssi.bg>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
To: Aaron Conole <aconole@bytheb.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170412203812.15091-1-aconole@bytheb.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 12, 2017 at 04:38:12PM -0400, Aaron Conole wrote:
> The sync_refresh_period variable is unsigned, so it can never be < 0.
> 
> Signed-off-by: Aaron Conole <aconole@bytheb.org>

Thanks Aaron,

I have applied this to ipvs-next after updating the prefix to "ipvs:".
