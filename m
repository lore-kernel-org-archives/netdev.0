From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net V4 0/2] igb: ptp hardware clock
Date: Fri, 27 Jan 2012 13:11:55 +0100
Message-ID: <20120127121155.GA5380@cherladcori01>
References: <cover.1327161325.git.richardcochran@gmail.com>
 <1327638293.2729.43.camel@jtkirshe-mobl>
 <20120127101119.GA6690@netboy.at.omicron.at>
 <1327659327.2729.55.camel@jtkirshe-mobl>
 <1327659761.2220.0.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <1327661789.2729.57.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"Brown, Aaron F" <aaron.f.brown@intel.com>, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net,
	Jacob Keller <jacob.e.keller@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	Thomas Gleixner <tglx@linutronix.de>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:47099 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752842Ab2A0MMI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2012 07:12:08 -0500
Received: by wics10 with SMTP id s10so1155501wic.19
        for <netdev@vger.kernel.org>; Fri, 27 Jan 2012 04:12:07 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1327661789.2729.57.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 27, 2012 at 02:56:29AM -0800, Jeff Kirsher wrote:
> Eric was correct.  I added #include <linux/mdoule.h> to the igb_ptp.c
> file and the error goes away.
> 
> Richard are you fine with me adding that change to your first patch of
> the series?  That way I can have the validation team finish up testing
> your patches.

By all means, please go right ahead.

Thanks,
Richard
