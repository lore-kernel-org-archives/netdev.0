From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next 2/2] igb: offer a PTP Hardware Clock instead
 of the timecompare method
Date: Sun, 25 Dec 2011 12:30:52 +0100
Message-ID: <20111225113051.GA20094@netboy.at.omicron.at>
References: <cover.1323744724.git.richardcochran@gmail.com>
 <388385c50909f63bff239894c60dbb00abc65c93.1323744725.git.richardcochran@gmail.com>
 <1323901989.19702.12.camel@jbrandeb-mobl2>
 <20111215161256.GA5176@cherladcori01>
 <EDC0E76513226749BFBC9C3FB031318F018669B7BB@orsmsx508.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"Keller, Jacob E" <jacob.e.keller@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	Thomas Gleixner <tglx@linutronix.de>
To: "Wyborny, Carolyn" <carolyn.wyborny@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:55332 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753271Ab1LYLbE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Dec 2011 06:31:04 -0500
Received: by eekc4 with SMTP id c4so10519968eek.19
        for <netdev@vger.kernel.org>; Sun, 25 Dec 2011 03:31:02 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <EDC0E76513226749BFBC9C3FB031318F018669B7BB@orsmsx508.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 15, 2011 at 08:46:55AM -0800, Wyborny, Carolyn wrote:
> >-----Original Message-----
> >From: Richard Cochran [mailto:richardcochran@gmail.com]
...
> >Any chance of getting the driver tested on a 82576?
> >
> >Thanks,
> >
> >Richard
> 
> I will request this testing and let you know.

Never mind about testing this patch. I have already found a bug in the
code path for the 82576. I will post a new, corrected patch later on
this week.

Thanks, and Merry Christmas to All,

Richard
