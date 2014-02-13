From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 00/15] Intel Wired LAN Driver Updates
Date: Thu, 13 Feb 2014 17:27:54 -0500 (EST)
Message-ID: <20140213.172754.2143025631014243071.davem@davemloft.net>
References: <1392292133-32120-1-git-send-email-aaron.f.brown@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: aaron.f.brown@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50741 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752312AbaBMW15 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 17:27:57 -0500
In-Reply-To: <1392292133-32120-1-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Aaron Brown <aaron.f.brown@intel.com>
Date: Thu, 13 Feb 2014 03:48:38 -0800

> This series contains updates to i40e and i40evf, primarily reset
> handling / refactoring along with a fair amount of minor cleanup.
> 
> Jesse fixes some spelling, bumps the version and other trivial fixes.
> Akeem sets a bit that is needed before shutdown in the case of 
> tx_timeout recovery failure.  Mitch refactors reset handling along 
> with a whole bunch of clean up.

Series applied, thanks.
