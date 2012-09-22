From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH V2 net-next 0/4] Two new PTP Hardware Clock features
Date: Sat, 22 Sep 2012 09:45:53 +0200
Message-ID: <20120922074553.GA4143@netboy.at.omicron.at>
References: <cover.1348299094.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	Jacob Keller <jacob.e.keller@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	Matthew Vick <matthew.vick@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:41016 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753707Ab2IVHqF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Sep 2012 03:46:05 -0400
Received: by wgbfm10 with SMTP id fm10so1558621wgb.1
        for <netdev@vger.kernel.org>; Sat, 22 Sep 2012 00:46:03 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <cover.1348299094.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 22, 2012 at 09:42:52AM +0200, Richard Cochran wrote:
> This patch series adds two new features to the PHC code.

Forgot to say:

V2 preserves the clock_name attribute as it was meant to be, instead
of making any changes to it.

Thanks,
Richard
