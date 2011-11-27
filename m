From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH net-next 1/8] dsa: Change dsa_uses_{dsa,trailer}_tags()
 into inline functions
Date: Sun, 27 Nov 2011 20:12:32 +0100
Message-ID: <20111127191232.GP795@wantstofly.org>
References: <1322267572.2839.381.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fw.wantstofly.org ([80.101.37.227]:65490 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753397Ab1K0TU7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Nov 2011 14:20:59 -0500
Content-Disposition: inline
In-Reply-To: <1322267572.2839.381.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 26, 2011 at 12:32:52AM +0000, Ben Hutchings wrote:

> eth_type_trans() will use these functions if DSA is enabled, which
> blocks building DSA as a module.

Acked-by: Lennert Buytenhek <buytenh@wantstofly.org>
