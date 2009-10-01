From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 3/4] net: Convert ethtool {get_stats,self_test}_count()
	ops to get_sset_count()
Date: Thu, 01 Oct 2009 23:00:03 +0100
Message-ID: <1254434403.2735.36.camel@achroite>
References: <1254432754.2735.27.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Chien Tung <chien.tin.tung@intel.com>,
	Faisal Latif <faisal.latif@intel.com>,
	Subbu Seetharaman <subbus@serverengines.com>,
	Sathya Perla <sathyap@serverengines.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Josh Boyer <jwboyer@linux.vnet.ibm.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:4271 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752608AbZJAWAE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2009 18:00:04 -0400
In-Reply-To: <1254432754.2735.27.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Due to a mis-paste, I originally sent this to the invalid
etdev@vger.kernel.org and not netdev@.  You'll need to fix that when
replying.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

