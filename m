From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH][NET] ifb: set separate lockdep classes for queue locks
Date: Wed, 19 Mar 2008 07:34:29 -0400
Message-ID: <1205926469.4440.25.camel@localhost>
References: <20080307075113.GA3912@ff.dom.local>
	 <1204898002.4431.99.camel@localhost> <20080308084628.GA2749@ami.dom.local>
	 <20080308085854.GB2749@ami.dom.local> <20080308101540.M65133@visp.net.lb>
	 <20080308104322.GA3301@ami.dom.local> <20080308105250.GB3301@ami.dom.local>
	 <20080308110611.M62976@visp.net.lb> <20080308120244.GA3378@ami.dom.local>
	 <20080319004547.M71837@visp.net.lb>  <20080319073441.GA3918@ff.dom.local>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>,
	"David S. Miller" <davem@davemloft.net>,
	Denys Fedoryshchenko <denys@visp.net.lb>,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.178]:30906 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754446AbYCSTyD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2008 15:54:03 -0400
Received: by py-out-1112.google.com with SMTP id u52so742874pyb.10
        for <netdev@vger.kernel.org>; Wed, 19 Mar 2008 12:54:03 -0700 (PDT)
In-Reply-To: <20080319073441.GA3918@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-19-03 at 07:34 +0000, Jarek Poplawski wrote:

Thanks for logging the false-positive aspect Jarek.

> Reported-and-tested-by: Denys Fedoryshchenko <denys@visp.net.lb>
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
> Cc: Jamal Hadi Salim <hadi@cyberus.ca>

Acked-by: Jamal Hadi Salim <hadi@cyberus.ca>

cheers,
jamal

