From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/5] tcp: allow autoloading of congestion control via
 setsockopt
Date: Thu, 09 Nov 2006 16:36:48 -0800 (PST)
Message-ID: <20061109.163648.40181141.davem@davemloft.net>
References: <20061031230140.191929094@osdl.org>
	<20061031230214.056079805@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:7300
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1424315AbWKJAgy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Nov 2006 19:36:54 -0500
To: shemminger@osdl.org
In-Reply-To: <20061031230214.056079805@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Tue, 31 Oct 2006 15:01:44 -0800

> If user has permision to load modules, then autoload then attempt
> autoload of TCP congestion module.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

Applied, thanks.
