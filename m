From: David Miller <davem@davemloft.net>
Subject: Re: netlink: constify struct nlattr * arg to parsing functions
Date: Tue, 28 Oct 2008 11:59:25 -0700 (PDT)
Message-ID: <20081028.115925.206686944.davem@davemloft.net>
References: <490730CC.2050800@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51763
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751495AbYJ1S7s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2008 14:59:48 -0400
In-Reply-To: <490730CC.2050800@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Tue, 28 Oct 2008 16:33:32 +0100

>     netlink: constify struct nlattr * arg to parsing functions
>     
>     Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied to net-next-2.6, thanks Patrick.
