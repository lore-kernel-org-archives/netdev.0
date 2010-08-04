From: xeb@mail.ru
Subject: =?koi8-r?Q?Re[2]=3A_[PATCH_2/3]_PPTP=3A_PPP_over_IPv4_(Point-to-Point_Tunneling_Protocol)?=
Date: Thu, 05 Aug 2010 00:36:25 +0400
Message-ID: <E1OgkhN-0004sl-00.xeb-mail-ru@f252.mail.ru>
References: <1280949557.11056.2.camel@dcbw.foobar.com>
Reply-To: xeb@mail.ru
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from f252.mail.ru ([217.69.128.177]:57547 "EHLO f252.mail.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935532Ab0HDUgn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Aug 2010 16:36:43 -0400
In-Reply-To: <1280949557.11056.2.camel@dcbw.foobar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Can this be used in place of the userspace ppp+pptp combo?  If so, how
> would I go about setting that up?
> 
> Dan

Yes of course, you need plugin for pppd which you can get from accel-pptp package ( http://sourceforge.net/projects/accel-pptp/ ). Also it contains instruction how to use it.

