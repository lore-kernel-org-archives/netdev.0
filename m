From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [net-next 1/6] igb: Tidy up wrapping for CONFIG_IGB_PTP.
Date: Thu, 6 Sep 2012 10:09:38 +0200
Message-ID: <20120906080938.GE2550@netboy.at.omicron.at>
References: <1346888106-25638-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1346888106-25638-2-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, Matthew Vick <matthew.vick@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:59730 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752760Ab2IFIJu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Sep 2012 04:09:50 -0400
Received: by wibhr14 with SMTP id hr14so1119780wib.1
        for <netdev@vger.kernel.org>; Thu, 06 Sep 2012 01:09:49 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1346888106-25638-2-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 05, 2012 at 04:35:01PM -0700, Jeff Kirsher wrote:
> From: Matthew Vick <matthew.vick@intel.com>
> 
> For users without CONFIG_IGB_PTP=y, we should not be compiling any PTP
> code into the driver. Tidy up the wrapping in igb to support this.

So, you have ignored everything I wrote about time stamping
applications.

(no)Thanks,
Richard
