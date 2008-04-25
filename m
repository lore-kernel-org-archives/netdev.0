From: David Miller <davem@davemloft.net>
Subject: Re: [DCCP] [RFC] [Patchv2 1/1]: Queuing policies -- reworked
 version of Tomasz's patch set
Date: Fri, 25 Apr 2008 13:58:16 -0700 (PDT)
Message-ID: <20080425.135816.197801806.davem@davemloft.net>
References: <20080422.154212.108914213.davem@davemloft.net>
	<200804252133.11264.tomasz@grobelny.oswiecenia.net>
	<20080425204024.GA16635@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tomasz@grobelny.oswiecenia.net, gerrit@erg.abdn.ac.uk,
	dccp@vger.kernel.org, netdev@vger.kernel.org
To: acme@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44755
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753263AbYDYU6Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Apr 2008 16:58:16 -0400
In-Reply-To: <20080425204024.GA16635@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Fri, 25 Apr 2008 17:40:24 -0300

> I haven't read all the patches, but I guess Tomasz is on the safe side
> as the intended skb->priority usage is limited to DCCP, when IP is
> handed the skb it can do as it pleases with skb->priority.

Great.
