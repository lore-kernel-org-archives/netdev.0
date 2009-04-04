From: David Miller <davem@davemloft.net>
Subject: Re: [Regression, in, 2.6.29] forcedeth doesn't work after resume
 from hibernation (was: Re: Resume after hibernation regression in 2.6.29)
Date: Sat, 04 Apr 2009 16:54:21 -0700 (PDT)
Message-ID: <20090404.165421.142076064.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eswierk@aristanetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39650
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754174AbZDDXyc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Apr 2009 19:54:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Please send a version of this patch that actually applies to
Linus's tree, the line numbers et al. are a lot different
now.

I'll backport and submit that to -stable.

Thanks.
