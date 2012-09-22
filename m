From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH V3 net-next 4/4] ptp: clarify the clock_name sysfs
 attribute
Date: Sat, 22 Sep 2012 18:20:01 +0100
Message-ID: <1348334401.2521.105.camel@bwh-desktop.uk.solarflarecom.com>
References: <cover.1348332940.git.richardcochran@gmail.com>
	 <149b5cc1b5813bb4052f8dff4cbe0b5be62d086e.1348332941.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>,
	Jacob Keller <jacob.e.keller@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	Matthew Vick <matthew.vick@intel.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:48591 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752181Ab2IVRUF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Sep 2012 13:20:05 -0400
In-Reply-To: <149b5cc1b5813bb4052f8dff4cbe0b5be62d086e.1348332941.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2012-09-22 at 19:02 +0200, Richard Cochran wrote:
> There has been some confusion among PHC driver authors about the
> intended purpose of the clock_name attribute. This patch expands the
> documation in order to clarify how the clock_name field should be
> understood.
> 
> Signed-off-by: Richard Cochran <richardcochran@gmail.com>
[...]

Looks good, thanks.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
