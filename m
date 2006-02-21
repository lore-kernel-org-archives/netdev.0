From: Roland Dreier <rdreier@cisco.com>
Subject: Re: Re: [PATCH RESEND] net: Move destructor from
	neigh->ops to neigh_params
Date: Mon, 20 Feb 2006 20:48:30 -0800
Message-ID: <adahd6t5nc1.fsf@cisco.com>
References: <adabqxq1rdh.fsf@cisco.com>
	<20060202.103448.118065476.yoshfuji@linux-ipv6.org>
	<adalkw55qdq.fsf@cisco.com>
	<20060220.200152.00014728.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060220.200152.00014728.davem@davemloft.net> (David S.
	Miller's message of "Mon, 20 Feb 2006 20:01:52 -0800 (PST)")
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

    David> Not yet, it's very low on the priority list at the moment,
    David> but I do still have it in my inbox so don't worry.

Do you think you'll get a chance to look at it for 2.6.17?  If not we
can work around things in the IPoIB driver in a slightly uglier way
for 2.6.17.

Thanks,
  Roland
