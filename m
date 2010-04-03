From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 0/3] GTSM support for IPv6 three alternatives
Date: Sat, 03 Apr 2010 16:21:03 -0700
Message-ID: <20100403232103.923025940@vyatta.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, Pekka Savola <pekkas@netcore.fi>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Nick Hilliard <nick@inex.ie>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:46436 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751240Ab0DCXbf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 3 Apr 2010 19:31:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have tested three alternative versions of this patch and can't
reach a diffinitive conclusion.  I favor the unified version (simplest API),
but need more opinions.  It would not be good if Linux implements
one option and BSD choose the other! That is why the original 
BSD developer and the quagga patch author are receiving this.

In case it is not obvious, only one of these choices should be
applied!

-- 

