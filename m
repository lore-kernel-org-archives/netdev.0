From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] net: check for NULL net_device in FIB tables
Date: Tue, 5 Jul 2016 01:15:36 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1607050114010.2228@ja.home.ssi.bg>
References: <1467636446-6771-1-git-send-email-vegard.nossum@oracle.com> <alpine.LFD.2.11.1607042221290.2228@ja.home.ssi.bg> <577ABF71.6020002@oracle.com> <alpine.LFD.2.11.1607050014000.2228@ja.home.ssi.bg> <577ADCE1.6010506@oracle.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andy Gospodarek <gospo@cumulusnetworks.com>, davem@davemloft.net,
	netdev@vger.kernel.org, Dinesh Dutt <ddutt@cumulusnetworks.com>,
	Scott Feldman <sfeldma@gmail.com>
To: Vegard Nossum <vegard.nossum@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:55003 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752357AbcGDWPw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jul 2016 18:15:52 -0400
In-Reply-To: <577ADCE1.6010506@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Tue, 5 Jul 2016, Vegard Nossum wrote:

> > [PATCH RFC] ipv4: reject RTNH_F_LINKDOWN for incompatible routes
> >
> > The RTNH_F_LINKDOWN flag is used only for link routes.
> > Reject it for error routes and local routes.
> >
> > Signed-off-by: Julian Anastasov <ja@ssi.bg>
> 
> Tested your patch, it fixes the problem for me. I haven't tested if it
> breaks anything else :-)

	Thanks!

Regards
