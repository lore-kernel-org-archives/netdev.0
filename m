From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2]: net: Do software flow seperation on receive.
Date: Fri, 26 Jun 2009 16:52:30 -0700 (PDT)
Message-ID: <20090626.165230.68583655.davem@davemloft.net>
References: <20080917.193442.232214911.davem@davemloft.net>
	<alpine.LNX.1.10.0906270136390.23295@bizon.gios.gov.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jens.axboe@oracle.com,
	nickpiggin@yahoo.com.au
To: ole@ans.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40107
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751311AbZFZXw0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2009 19:52:26 -0400
In-Reply-To: <alpine.LNX.1.10.0906270136390.23295@bizon.gios.gov.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krzysztof Oledzki <ole@ans.pl>
Date: Sat, 27 Jun 2009 01:40:35 +0200 (CEST)

> What is the future of this patch? Was it only a proof of concept or is
> it going to be included in the mainline one day?

Lots of work and thinking is necessary to do this right.

Maybe something will be integrated into my tree in the
next few months or so.
