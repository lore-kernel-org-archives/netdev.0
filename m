From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next  07/10] ixgbe: fix SFF data dumps of SFP+ modules
 from an offset
Date: Thu, 29 Aug 2013 02:00:11 +0100
Message-ID: <1377738011.2264.46.camel@bwh-desktop.uk.level5networks.com>
References: <1377686028-30747-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1377686028-30747-8-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, Emil Tantilov <emil.s.tantilov@intel.com>,
	<netdev@vger.kernel.org>, <gospo@redhat.com>, <sassmann@redhat.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:46421 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752194Ab3H2BAR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Aug 2013 21:00:17 -0400
In-Reply-To: <1377686028-30747-8-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-08-28 at 03:33 -0700, Jeff Kirsher wrote:
> From: Emil Tantilov <emil.s.tantilov@intel.com>
> 
> This patch fixes the read loop for the I2C data to account for the offset.
> 
> Also includes a whitespace cleanup and removes ret_val as it is not needed.
> 
> CC: Ben Hutchings <bhutchings@solarflare.com>
> Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
> Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
> Reported-by: Ben Hutchings <bhutchings@solarflare.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
[...]

Reviewed-by: Ben Hutchings <bhutchings@solarflare.com>

Thanks.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
