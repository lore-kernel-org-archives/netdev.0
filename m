From: Roland Dreier <rdreier@cisco.com>
Subject: Re: Re: [PATCH RESEND] net: Move destructor from
	neigh->ops to neigh_params
Date: Mon, 20 Feb 2006 19:42:41 -0800
Message-ID: <adalkw55qdq.fsf@cisco.com>
References: <adazmlmmy7v.fsf@cisco.com> <adabqxq1rdh.fsf@cisco.com>
	<20060202.103448.118065476.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: YOSHIFUJI Hideaki / =?iso-2022-jp?b?GyRCNUgbKEI=?= =?iso-2022-jp?b?GyRCRiMxUUxAGyhC?= <yoshfuji@linux-ipv6.org>,
	netdev@vger.kernel.org, openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: davem@davemloft.net
In-Reply-To: <20060202.103448.118065476.yoshfuji@linux-ipv6.org> (YOSHIFUJI
	Hideaki's message of "Thu, 02 Feb 2006 10:34:48 +0900 (JST)")
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

Hi Dave, have you had a chance to look at this?  I can resend again if
you've lost the original mail.  Also, let me know if you want me to
merge this through my tree when 2.6.17 opens up.

The only feedback I've seen is that Yoshfuji-san has said that this
looks sane.

Thanks,
  Roland
