From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xfrm: xfrm hash to use Jenkins' hash
Date: Thu, 06 Aug 2009 10:40:34 -0700 (PDT)
Message-ID: <20090806.104034.186857842.davem@davemloft.net>
References: <20090805.120831.66033097.davem@davemloft.net>
	<ce10d01f0908052332o1db16460k58ed47849670c6de@mail.gmail.com>
	<alpine.DEB.1.10.0908061147060.3426@sisapiiri.net.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joamaki@gmail.com, netdev@vger.kernel.org
To: jmaki@sisapiiri.net.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59569
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756428AbZHFRkY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Aug 2009 13:40:24 -0400
In-Reply-To: <alpine.DEB.1.10.0908061147060.3426@sisapiiri.net.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jussi Maki <jmaki@sisapiiri.net.net>
Date: Thu, 6 Aug 2009 11:58:55 +0300 (EEST)

> Did some testing and one possible fix to this problem
> would be to change the xor to addition. Would this be OK?

Yes.

Please make a formal submission.
