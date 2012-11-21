From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [net-next 08/10] igb: Update PTP Rx filters
Date: Wed, 21 Nov 2012 12:37:18 +0100
Message-ID: <20121121113718.GA2270@netboy.at.omicron.at>
References: <1353494856-12344-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1353494856-12344-9-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, Matthew Vick <matthew.vick@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:38566 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753542Ab2KULhX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2012 06:37:23 -0500
Received: by mail-ea0-f174.google.com with SMTP id e13so2755720eaa.19
        for <netdev@vger.kernel.org>; Wed, 21 Nov 2012 03:37:22 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1353494856-12344-9-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 21, 2012 at 02:47:34AM -0800, Jeff Kirsher wrote:
> From: Matthew Vick <matthew.vick@intel.com>
> 
> Update the filters to be more consistent with what the driver wants to do.
> For example, for devices that timestamp all packets, report that the filter
> is set for timestamping all packets.
> 
> Signed-off-by: Matthew Vick <matthew.vick@intel.com>
> Cc: Richard Cochran <richardcochran@gmail.com>
> Tested-by: Aaron Brown <aaron.f.brown@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Acked-by: Richard Cochran <richardcochran@gmail.com>
