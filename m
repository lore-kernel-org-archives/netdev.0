From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH RESEND] net: Move destructor from
 neigh->ops to neigh_params
Date: Fri, 03 Mar 2006 17:58:54 -0800 (PST)
Message-ID: <20060303.175854.128571811.davem@davemloft.net>
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

> Dave, if you want to merge this directly, that's fine.  Or I'm fine
> with merging this through the IB tree if you'd prefer (if you want me
> to do that, let me know if you think it's 2.6.16 material).

Applied to net-2.6.17, thanks for being so incredibly patient :)
