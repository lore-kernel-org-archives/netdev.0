From: David Miller <davem@davemloft.net>
Subject: Re: netdev-2.6 [PATCH 0/5] dccp: ccid-2/3 code clean up; TCP RTT
 estimator
Date: Mon, 23 Aug 2010 20:15:01 -0700 (PDT)
Message-ID: <20100823.201501.43015031.davem@davemloft.net>
References: <20100820.004005.58446090.davem@davemloft.net>
	<1282542100-5799-1-git-send-email-gerrit@erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45843
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751756Ab0HXDOo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Aug 2010 23:14:44 -0400
In-Reply-To: <1282542100-5799-1-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 23 Aug 2010 07:41:35 +0200

> please would you consider consider the following DCCP CCID-2/3 set (applies to
> netdev-2.6): it does code clean-up and adds a better RTO estimation to CCID-2.

Looks great, all applied to net-next-2.6, thanks!
