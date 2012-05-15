From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] Add the command to show the time stamping capabilities.
Date: Tue, 15 May 2012 19:08:27 +0100
Message-ID: <1337105307.2544.37.camel@bwh-desktop.uk.solarflarecom.com>
References: <cover.1333474520.git.richardcochran@gmail.com>
	 <1333475903-8185-1-git-send-email-richardcochran@gmail.com>
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
Received: from webmail.solarflare.com ([12.187.104.25]:35470 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756244Ab2EOSIg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 May 2012 14:08:36 -0400
In-Reply-To: <1333475903-8185-1-git-send-email-richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry for the delay in handling this.

I've applied this with a minor change: I renamed the long option to
--show-time-stamping, for consistency with other 'show' options and to
allow for future addition of other time stamping options.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
