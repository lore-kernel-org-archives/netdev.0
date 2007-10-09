From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3][NET_BATCH] net core use batching
Date: Tue, 09 Oct 2007 13:51:45 -0700 (PDT)
Message-ID: <20071009.135145.95506679.davem@davemloft.net>
References: <OF20E88706.D91FCF10-ON6525736F.003E50CD-6525736F.003E5E6F@in.ibm.com>
	<20071009.042441.30182968.davem@davemloft.net>
	<ada3awkhwbv.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, gaagaan@gmail.com,
	general@lists.openfabrics.org, hadi@cyberus.ca,
	herbert@gondor.apana.org.au, jagana@us.ibm.com, jeff@garzik.org,
	johnpol@2ka.mipt.ru, kaber@trash.net, mcarlson@broadcom.com,
	mchan@broadcom.com, netdev@vger.kernel.org,
	peter.p.waskiewicz.jr@intel.com, randy.dunlap@oracle.com,
	rick.jones2@hp.com, Robert.Olsson@data.slu.se,
	shemminger@linux-foundation.org, sri@us.ibm.com, tgraf@suug.ch,
	xma@us.ibm.com
To: rdreier@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41867
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753710AbXJIUvp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2007 16:51:45 -0400
In-Reply-To: <ada3awkhwbv.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Roland Dreier <rdreier@cisco.com>
Date: Tue, 09 Oct 2007 13:22:44 -0700

> I can definitely kill LLTX for IPoIB by 2.6.25 and I just added it to
> my TODO list so I don't forget.
> 
> In fact if 2.6.23 drags on long enough I may do it for 2.6.24....

Before you add new entries to your list, how is that ibm driver NAPI
conversion coming along? :-)

Right now that's a more pressing task to complete.
