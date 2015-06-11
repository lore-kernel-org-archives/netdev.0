From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net] net: igb: fix the start time for periodic output
 signals
Date: Thu, 11 Jun 2015 14:53:10 +0200
Message-ID: <20150611125310.GA26906@localhost.localdomain>
References: <1434027090-26866-1-git-send-email-richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Jacob Keller <jacob.e.keller@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Matthew Vick <matthew.vick@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:35900 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751906AbbFKMxP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2015 08:53:15 -0400
Received: by wigg3 with SMTP id g3so74737929wig.1
        for <netdev@vger.kernel.org>; Thu, 11 Jun 2015 05:53:14 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1434027090-26866-1-git-send-email-richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 11, 2015 at 02:51:30PM +0200, Richard Cochran wrote:
> This patch fixes the issue by programming the registers correctly.

Please also consider this for stable.

Thanks,
Richard
