From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH RESEND] net: Move destructor from
 neigh->ops to neigh_params
Date: Wed, 01 Feb 2006 17:33:39 -0800
Message-ID: <ada7j8e1r4c.fsf@cisco.com>
References: <adazmlmmy7v.fsf@cisco.com> <adabqxq1rdh.fsf@cisco.com>
	<20060201.173137.10844554.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: netdev@vger.kernel.org, openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060201.173137.10844554.davem@davemloft.net> (David S.
	Miller's message of "Wed, 01 Feb 2006 17:31:37 -0800 (PST)")
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

    David> It's sitting in my backlog, and will be a net-2.6.17 issue
    David> not a net-2.6.16 one as we're in bug fix mode there.

    David> Sorry if you need this in 2.6.16, but that's not really
    David> practical.

No, that's fine... I was just resending in case you were using RED to
manage your backlog.  This is a real issue but I don't think it's
hitting a lot of people.

 - R.
