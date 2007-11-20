From: David Miller <davem@davemloft.net>
Subject: Re: [patch 3/3] IPVS: Move remaining sysctl handlers over to
 CTL_UNNUMBERED
Date: Mon, 19 Nov 2007 21:51:26 -0800 (PST)
Message-ID: <20071119.215126.219391970.davem@davemloft.net>
References: <20071114180615.251592665@natsuko.shinjuku.tokyo.vergenet.net>
	<20071114180824.652798827@natsuko.shinjuku.tokyo.vergenet.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ebiederm@xmission.com,
	wensong@linux-vs.org, ja@ssi.bg, borntraeger@de.ibm.com
To: horms@verge.net.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58557
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752272AbXKTFv1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 00:51:27 -0500
In-Reply-To: <20071114180824.652798827@natsuko.shinjuku.tokyo.vergenet.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Simon Horman <horms@verge.net.au>
Date: Wed, 14 Nov 2007 10:06:18 -0800

> Switch the remaining IPVS sysctl entries over to to use CTL_UNNUMBERED,
> I stronly doubt that anyone is using the sys_sysctl interface to
> these variables.
> 
> Cc: Eric W. Biederman <ebiederm@xmission.com>
> Cc: Wensong Zhang <wensong@linux-vs.org>
> Cc: Julian Anastasov <ja@ssi.bg>
> Cc: Christian Borntraeger <borntraeger@de.ibm.com>
> Signed-off-by: Simon Horman <horms@verge.net.au>

Also applied, thanks.
