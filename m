From: David Miller <davem@davemloft.net>
Subject: Re: net: fib_rules: fix error code for unsupported families
Date: Tue, 01 Jul 2008 20:00:04 -0700 (PDT)
Message-ID: <20080701.200004.228435434.davem@davemloft.net>
References: <4869405E.9030807@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53983
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758999AbYGBDAE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jul 2008 23:00:04 -0400
In-Reply-To: <4869405E.9030807@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Mon, 30 Jun 2008 22:21:50 +0200

>     net: fib_rules: fix error code for unsupported families
>     
>     The errno code returned must be negative.
>     
>     Fixes "RTNETLINK answers: Unknown error 18446744073709551519".
>     
>     Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied to net-2.6, thanks!
