From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH v1] iproute2: add IFLA_TC support to 'ip link'
Date: Wed, 01 Dec 2010 10:48:23 -0800 (PST)
Message-ID: <20101201.104823.59686720.davem@davemloft.net>
References: <20101201182758.3297.34345.stgit@jf-dev1-dcblab>
	<20101201103802.11464029@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
	tgraf@infradead.org, eric.dumazet@gmail.com
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47172
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756186Ab0LASr4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Dec 2010 13:47:56 -0500
In-Reply-To: <20101201103802.11464029@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 1 Dec 2010 10:38:02 -0800

> Ok. but will not be applied until after 2.6.38 (when kernel support
> is upstream).

Speaking of which, Stephen could you please process the iproute2 patches
which have been rotting in the patchwork queue since... May?!

Just reject them if you don't plan to apply them.  Letting them just sit
around there for half a year bothers me (and patch submitters) a lot.

