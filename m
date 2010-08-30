From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCH 1/1] TCP: update initial windows according to RFC
 5681
Date: Mon, 30 Aug 2010 13:51:23 -0700 (PDT)
Message-ID: <20100830.135123.241915070.davem@davemloft.net>
References: <20100830052734.GB5332@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56026
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753809Ab0H3UvH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Aug 2010 16:51:07 -0400
In-Reply-To: <20100830052734.GB5332@gerrit.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 30 Aug 2010 07:27:34 +0200

> This is an update to the earlier DCCP 5-patch set, sent separately in case this
> question is a contentious issue. 
> 
> However, it does look as if the newer RFC 5681 is indeed the normative case for 
> the RFC 3390 initial window value. 
> 
> If there are no objections, I would like to submit this as an update for net-2.6.

I don't have any objectioned but I'm going to put it into net-next-2.6
as I don't see any real reason to rush something like this.

Thanks!
