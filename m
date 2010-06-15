From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: IPv6 stops working after ethtool diagnostic
Date: Tue, 15 Jun 2010 19:16:32 +0100
Message-ID: <1276625792.2078.12.camel@achroite.uk.solarflarecom.com>
References: <EA929A9653AAE14F841771FB1DE5A1365FF43AAD0F@rrsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"Pieper, Jeffrey E" <jeffrey.e.pieper@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:58542 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752535Ab0FOSQg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jun 2010 14:16:36 -0400
In-Reply-To: <EA929A9653AAE14F841771FB1DE5A1365FF43AAD0F@rrsmsx501.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-06-15 at 12:05 -0600, Tantilov, Emil S wrote:
> We ran into a problem on net-next where IPv6 traffic fails after running ethtool -t:

Are you going to report which driver is responsible for eth0 or are are
you going to let us guess?

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

