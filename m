From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH] IPoIB: Fix build now that destructor
	is in neigh_params
Date: Tue, 07 Mar 2006 14:56:44 -0800
Message-ID: <adawtf5rhhv.fsf@cisco.com>
References: <adazmlmmy7v.fsf@cisco.com>
	<20060306211630.0df79464.akpm@osdl.org> <adawtf6rrh7.fsf_-_@cisco.com>
	<20060307.145350.77989471.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@osdl.org, netdev@vger.kernel.org, openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060307.145350.77989471.davem@davemloft.net> (David S. Miller's
	message of "Tue, 07 Mar 2006 14:53:50 -0800 (PST)")
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

    David> Why not just put this into your -ipoib patch set in -mm?
    David> The change was for IPOIB's sake anyways...

OK, good idea.  I'll put this in my for-2.6.17 and for-mm queues.

 - R.
