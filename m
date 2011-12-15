From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next 2/2] igb: offer a PTP Hardware Clock instead of
 the timecompare method
Date: Thu, 15 Dec 2011 17:12:56 +0100
Message-ID: <20111215161256.GA5176@cherladcori01>
References: <cover.1323744724.git.richardcochran@gmail.com>
 <388385c50909f63bff239894c60dbb00abc65c93.1323744725.git.richardcochran@gmail.com>
 <1323901989.19702.12.camel@jbrandeb-mobl2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"Keller, Jacob E" <jacob.e.keller@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>
To: Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:41551 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758987Ab1LOQNJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Dec 2011 11:13:09 -0500
Received: by eaaj10 with SMTP id j10so2065521eaa.19
        for <netdev@vger.kernel.org>; Thu, 15 Dec 2011 08:13:08 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1323901989.19702.12.camel@jbrandeb-mobl2>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 14, 2011 at 02:33:09PM -0800, Jesse Brandeburg wrote:
> On Mon, 2011-12-12 at 19:00 -0800, Richard Cochran wrote:
> > This commit removes the legacy timecompare code from the igb driver and
> > offers a tunable PHC instead.
> > 
> > Signed-off-by: Richard Cochran <richardcochran@gmail.com>
> 
> Richard, first, thanks for this work, I have some feedback and request
> you make a V2.

Thanks for your feedback, I'll will work your comments in.

Any chance of getting the driver tested on a 82576?

Thanks,

Richard
