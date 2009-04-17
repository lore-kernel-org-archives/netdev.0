From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net next] myri10ge: fix compile error
Date: Fri, 17 Apr 2009 15:45:42 -0700 (PDT)
Message-ID: <20090417.154542.235044419.davem@davemloft.net>
References: <49E8B8FD.8060100@myri.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, brice@myri.com
To: gallatin@myri.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52284
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752355AbZDQWpu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2009 18:45:50 -0400
In-Reply-To: <49E8B8FD.8060100@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Gallatin <gallatin@myri.com>
Date: Fri, 17 Apr 2009 13:14:37 -0400

> A compilation error snuck into
> 2d90b0aa3bc484189940444bcddcbe0ebbb53af5
> due to an over-zealous indent script removing spaces around array
> initialization ellipsis.  The attached patch fixes the myri10ge
> compilation in net-next.
> 
> Signed-off-by: Andrew Gallatin <gallatin@myri.com>

It gives me great confidence in your work, seeing as you don't
even type 'make' on the patches you send me.

Sigh, applied...

