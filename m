From: David Miller <davem@davemloft.net>
Subject: Re: net-next-2.6 [PATCH 1/1] tcp: add missing initial window (RFC
 3390) for tcp_output
Date: Wed, 01 Sep 2010 18:18:44 -0700 (PDT)
Message-ID: <20100901.181844.139103753.davem@davemloft.net>
References: <20100901053443.GB5379@gerrit.erg.abdn.ac.uk>
	<428BF15F-19DC-459A-B54A-EC273ECF537E@comsys.rwth-aachen.de>
	<20100901102835.GA5686@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45327
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753411Ab0IBBS1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Sep 2010 21:18:27 -0400
In-Reply-To: <20100901102835.GA5686@gerrit.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 1 Sep 2010 12:28:35 +0200

> Addressing comments from Alexander, removing comment.
> 
>>>>>>>>>>>>>>>>>>>>>>>> Patch v2 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
> tcp: update also tcp_output with regard to RFC 5681
> 
> Thanks to Ilpo Jarvinen, this updates also the initial window
> setting for tcp_output with regard to RFC 5681.
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Applied to net-next-2.6, thanks.
