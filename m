From: David Miller <davem@davemloft.net>
Subject: Re: [DCCP] [RFC] [Patchv2 1/1]: Queuing policies -- reworked
 version of Tomasz's patch set
Date: Mon, 28 Apr 2008 00:39:06 -0700 (PDT)
Message-ID: <20080428.003906.43331329.davem@davemloft.net>
References: <20080422174152.GD6039@gerrit.erg.abdn.ac.uk>
	<20080422.154212.108914213.davem@davemloft.net>
	<20080428072128.GB5379@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tomasz@grobelny.oswiecenia.net, dccp@vger.kernel.org,
	netdev@vger.kernel.org
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49053
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1763116AbYD1HjG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2008 03:39:06 -0400
In-Reply-To: <20080428072128.GB5379@gerrit.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 28 Apr 2008 08:21:28 +0100

> Since I can currently not see the last point happen within DCCP, I think
> that the use of skb->priority for layer 4 (DCCP) is safe.

Ok.

> So the remaining question was whether maintainers would be okay with
> this "overloading" of the field (Arnaldo seems ok with it). 

I'm okay with it, thanks for the explanation and analysis.
