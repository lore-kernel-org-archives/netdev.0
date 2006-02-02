From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH RESEND] net: Move destructor from
 neigh->ops to neigh_params
Date: Wed, 01 Feb 2006 17:31:37 -0800 (PST)
Message-ID: <20060201.173137.10844554.davem@davemloft.net>
References: <adazmlmmy7v.fsf@cisco.com>
	<adabqxq1rdh.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: rdreier@cisco.com
In-Reply-To: <adabqxq1rdh.fsf@cisco.com>
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
Date: Wed, 01 Feb 2006 17:28:10 -0800

> Sorry to distract everyone from the VJ channel discussion, but on the
> other hand it looks like Dave is back... I'm resending this because
> I'd really like to get this problem fixed but I want to make sure
> we're doing it the right way.  So either an ACK or a NAK with guidance
> would be great...

It's sitting in my backlog, and will be a net-2.6.17 issue not
a net-2.6.16 one as we're in bug fix mode there.

Sorry if you need this in 2.6.16, but that's not really practical.
