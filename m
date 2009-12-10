From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: export the number of times the recv queue was full
Date: Thu, 10 Dec 2009 14:02:34 -0800 (PST)
Message-ID: <20091210.140234.161691808.davem@davemloft.net>
References: <20091210210920.6820.12664.stgit@paris.rdu.redhat.com>
	<4B216A61.7020704@hp.com>
	<1260481947.2784.33.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, netdev@vger.kernel.org
To: eparis@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37178
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1761030AbZLJWC1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2009 17:02:27 -0500
In-Reply-To: <1260481947.2784.33.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Paris <eparis@redhat.com>
Date: Thu, 10 Dec 2009 16:52:27 -0500

> It could as a post processing measure be used to find this situation.  I
> believe they want a more 'on the fly' method.

Then use tracepoints.
