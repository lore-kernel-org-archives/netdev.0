From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH RESEND] net: Move destructor from
 neigh->ops to neigh_params
Date: Thu, 02 Feb 2006 10:34:48 +0900 (JST)
Message-ID: <20060202.103448.118065476.yoshfuji@linux-ipv6.org>
References: <adazmlmmy7v.fsf@cisco.com>
	<adabqxq1rdh.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	davem@davemloft.net, openib-general@openib.org
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

In article <adabqxq1rdh.fsf@cisco.com> (at Wed, 01 Feb 2006 17:28:10 -0800), Roland Dreier <rdreier@cisco.com> says:

> Sorry to distract everyone from the VJ channel discussion, but on the
> other hand it looks like Dave is back... I'm resending this because
> I'd really like to get this problem fixed but I want to make sure
> we're doing it the right way.  So either an ACK or a NAK with guidance
> would be great...

Sorry for silence.
Since we have "setup," it'd be natural to have destruct;
I seems sane to me.

--yoshfuji
