From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next 0/4] igb: auxiliary PHC functions for the i210.
Date: Wed, 19 Nov 2014 07:31:03 +0100
Message-ID: <20141119063103.GA4109@localhost.localdomain>
References: <cover.1416265321.git.richardcochran@gmail.com>
 <1416266118.2983.3.camel@jtkirshe-mobl.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	bruce.w.allan@intel.com, Jacob Keller <jacob.e.keller@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Matthew Vick <matthew.vick@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:47059 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754409AbaKSGbJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2014 01:31:09 -0500
Received: by mail-wi0-f171.google.com with SMTP id bs8so4265617wib.4
        for <netdev@vger.kernel.org>; Tue, 18 Nov 2014 22:31:07 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1416266118.2983.3.camel@jtkirshe-mobl.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 17, 2014 at 03:15:18PM -0800, Jeff Kirsher wrote:
> Thanks Richard, I have added your series of igb patches to my queue.

Jeff, please hold off on these. I found a bug in the PPS code. I will
re-submit with a fix.

Thanks,
Richard
