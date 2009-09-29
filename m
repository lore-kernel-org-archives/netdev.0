From: David Miller <davem@davemloft.net>
Subject: Re: [Bonding-devel] [PATCH 4/4] bonding: add sysfs files to
 display tlb and alb hash table contents
Date: Mon, 28 Sep 2009 17:44:19 -0700 (PDT)
Message-ID: <20090928.174419.211597516.davem@davemloft.net>
References: <20090911211317.GT8515@gospo.rdu.redhat.com>
	<20090928162237.6db0c9f5@nehalam>
	<20090929001203.GE4436@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org, fubar@us.ibm.com,
	bonding-devel@lists.sourceforge.net
To: andy@greyhouse.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58467
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753616AbZI2AoA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Sep 2009 20:44:00 -0400
In-Reply-To: <20090929001203.GE4436@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Gospodarek <andy@greyhouse.net>
Date: Mon, 28 Sep 2009 20:12:03 -0400

> Seemingly arbitrary requests like this are extremely annoying when the
> current kernel violates them all over the place.

And two wrongs don't make a right.

Just because things are not enforced properly elsewhere doesn't
mean we can be knowingly oblivious to the issue on new stuff.

Please adhere to Stephen's request, it's legitimate.

