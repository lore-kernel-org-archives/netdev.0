From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH] Consolidate sctp_ulpq_renege_xxx functions
Date: Tue, 23 Oct 2007 11:57:42 -0400
Message-ID: <471E19F6.7020800@hp.com>
References: <471E1082.8010607@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	lksctp-developers@lists.sourceforge.net,
	Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel8.hp.com ([156.153.255.206]:53566 "EHLO atlrel8.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752579AbXJWP5y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Oct 2007 11:57:54 -0400
In-Reply-To: <471E1082.8010607@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pavel Emelyanov wrote:
> Both are equal, except for the list to be traversed.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> 

ACK.  Good clean-up Pavel.

Thanks
-vlad
