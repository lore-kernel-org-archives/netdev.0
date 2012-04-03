From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH V3 net-next 08/28] ethtool: Add a common function for
 drivers with transmit time stamping.
Date: Tue, 3 Apr 2012 20:27:30 +0100
Message-ID: <1333481250.2577.37.camel@bwh-desktop.uk.solarflarecom.com>
References: <cover.1333474520.git.richardcochran@gmail.com>
	 <a7ec1893167462243c5657d7ad9a8ef4b20d5e97.1333474523.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>,
	Martin Porter <mporter@solarflare.com>,
	Jacob Keller <jacob.e.keller@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	<e1000-devel@lists.sourceforge.net>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:26347 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753765Ab2DCT1e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2012 15:27:34 -0400
In-Reply-To: <a7ec1893167462243c5657d7ad9a8ef4b20d5e97.1333474523.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-04-03 at 19:47 +0200, Richard Cochran wrote:
> Currently, most drivers do not support transmit SO_TIMESTAMPING. For those
> that do support it, there is one appropriate response to the get_ts_info
> query. This patch adds a common function providing this response.
> 
> Signed-off-by: Richard Cochran <richardcochran@gmail.com>
[...]
Reviewed-by: Ben Hutchings <bhutchings@solarflare.com>

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
