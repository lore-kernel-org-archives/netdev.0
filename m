From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Re: TSO and IPoIB performance degradation
Date: Tue, 07 Mar 2006 17:23:36 -0800 (PST)
Message-ID: <20060307.172336.107863253.davem@davemloft.net>
References: <1141776697.6119.938.camel@localhost>
	<20060307.161808.60227862.davem@davemloft.net>
	<adaacc1raz9.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	openib-general@openib.org, shemminger@osdl.org
Return-path: <openib-general-bounces@openib.org>
To: rdreier@cisco.com
In-Reply-To: <adaacc1raz9.fsf@cisco.com>
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

From: Roland Dreier <rdreier@cisco.com>
Date: Tue, 07 Mar 2006 17:17:30 -0800

> The reason TSO comes up is that reverting the patch described below
> helps (or helped at some point at least) IPoIB throughput quite a bit.

I wish you had started the thread by mentioning this specific
patch, we wasted an enormous amount of precious developer time
speculating and asking for arbitrary tests to be run in order
to narrow down the problem, yet you knew the specific change
that introduced the performance regression already...

This is a good example of how not to report a bug.
