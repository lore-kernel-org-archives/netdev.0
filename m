From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] net: fast consecutive name allocation
Date: Fri, 13 Nov 2009 18:59:37 -0800 (PST)
Message-ID: <20091113.185937.251557071.davem@davemloft.net>
References: <20091113233504.GQ19478@kvack.org>
	<20091113153924.6130135f@nehalam>
	<20091113235210.GR19478@kvack.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, opurdila@ixiacom.com,
	eric.dumazet@gmail.com, netdev@vger.kernel.org
To: bcrl@lhnet.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34003
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753908AbZKNC7V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2009 21:59:21 -0500
In-Reply-To: <20091113235210.GR19478@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin LaHaise <bcrl@lhnet.ca>
Date: Fri, 13 Nov 2009 18:52:10 -0500

> If you don't want the overhead from this kind of scaling, stick it under a 
> config option, but please don't stop other people from pushing Linux into 
> new uses which have these scaling requirements.

This 'scaling requirement' only exists in environments where people
undersubsribe their networks, right?

I'm not saying we won't put scaling into these areas, I'm just trying
to make a point to show that this "need" only exists because people
have purposefully created these situations where they feel the need to
massively control their users usage in order to generate revenue.
