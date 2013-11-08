From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [ethtool] ethtool: ixgbe DCB registers dump for 82599 and x540
Date: Fri, 8 Nov 2013 16:55:57 +0000
Message-ID: <1383929757.3802.25.camel@bwh-desktop.uk.level5networks.com>
References: <1380787887-6878-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Leonardo Potenza <leonardo.potenza@intel.com>,
	<netdev@vger.kernel.org>, <gospo@redhat.com>,
	<sassmann@redhat.com>, Maryam Tahhan <maryam.tahhan@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:17240 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757687Ab3KHQ4B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Nov 2013 11:56:01 -0500
In-Reply-To: <1380787887-6878-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-10-03 at 01:11 -0700, Jeff Kirsher wrote:
> From: Leonardo Potenza <leonardo.potenza@intel.com>
> 
> Added support for DCB registers dump using ethtool -d option both for
> 82599 and x540 ethernet controllers
> 
> Signed-off-by: Leonardo Potenza <leonardo.potenza@intel.com>
> Signed-off-by: Maryam Tahhan <maryam.tahhan@intel.com>
> Acked-by: John Fastabend <john.r.fastabend@intel.com>
> Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
> Tested-by: Jack Morgan <jack.morgan@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
[...]

Applied, thanks.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
