From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH-update][RFC] net: consolidated UDP / UDP-Lite code
Date: Thu, 12 Oct 2006 02:01:40 -0700 (PDT)
Message-ID: <20061012.020140.39159089.davem@davemloft.net>
References: <200609190825.23709@strip-the-willow>
	<200610091051.45021@strip-the-willow>
	<200610120849.19984@strip-the-willow>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:19424
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1161285AbWJLJBl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Oct 2006 05:01:41 -0400
To: gerrit@erg.abdn.ac.uk
In-Reply-To: <200610120849.19984@strip-the-willow>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 12 Oct 2006 08:49:19 +0100

> please find attached the updated UDP-Lite patch - I have removed the 
> statistics corrections you pointed out to me.
> 
> Can you please indicate whether you are ok, by and large, with the
> changes performed by the patch? Even if it is some time ago, I
> have implemented in this patch the architectural suggestions you
> gave me a while earlier. 

The patch looks pretty good.  I have no problems with how
you implemented this at all.

I think we'll have no problem getting this into 2.6.20
