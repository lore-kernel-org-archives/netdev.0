From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net V4 0/2] igb: ptp hardware clock
Date: Sat, 28 Jan 2012 09:26:50 +0100
Message-ID: <20120128082650.GA2275@netboy.at.omicron.at>
References: <cover.1327161325.git.richardcochran@gmail.com>
 <1327638293.2729.43.camel@jtkirshe-mobl>
 <20120127101119.GA6690@netboy.at.omicron.at>
 <1327659327.2729.55.camel@jtkirshe-mobl>
 <1327659761.2220.0.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <1327661789.2729.57.camel@jtkirshe-mobl>
 <20120127121155.GA5380@cherladcori01>
 <309B89C4C689E141A5FF6A0C5FB2118B2E07B8F1@ORSMSX101.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"Keller, Jacob E" <jacob.e.keller@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	Thomas Gleixner <tglx@linutronix.de>
To: "Brown, Aaron F" <aaron.f.brown@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:38769 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751530Ab2A1I1B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Jan 2012 03:27:01 -0500
Received: by eekc14 with SMTP id c14so807866eek.19
        for <netdev@vger.kernel.org>; Sat, 28 Jan 2012 00:27:00 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <309B89C4C689E141A5FF6A0C5FB2118B2E07B8F1@ORSMSX101.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 27, 2012 at 08:42:20PM +0000, Brown, Aaron F wrote:

> Yes, that does indeed resolve the compilation issue I was seeing in
> the lab, thanks...  I'm assuming a set of .config files that were
> failing is no longer necessary.

Right, don't need them anymore.

Thanks,
Richard
