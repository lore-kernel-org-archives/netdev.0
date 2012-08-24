From: "Vick, Matthew" <matthew.vick@intel.com>
Subject: RE: [net-next 11/13] igb: Update PTP function names/variables and
 locations.
Date: Fri, 24 Aug 2012 15:52:30 +0000
Message-ID: <06DFBC1E25D8024DB214DC7F41A3CD34488DDE99@ORSMSX101.amr.corp.intel.com>
References: <1345715813-20757-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1345715813-20757-12-git-send-email-jeffrey.t.kirsher@intel.com>
 <20120823111622.GC2238@netboy.at.omicron.at>
 <06DFBC1E25D8024DB214DC7F41A3CD34488DD079@ORSMSX101.amr.corp.intel.com>
 <20120823175335.GB2192@netboy.at.omicron.at>
 <02874ECE860811409154E81DA85FBB5807857EEA@ORSMSX105.amr.corp.intel.com>
 <20120823181117.GD2192@netboy.at.omicron.at>
 <06DFBC1E25D8024DB214DC7F41A3CD34488DD379@ORSMSX101.amr.corp.intel.com>
 <20120824065554.GB3261@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Keller, Jacob E" <jacob.e.keller@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:13001 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932354Ab2HXPwd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2012 11:52:33 -0400
In-Reply-To: <20120824065554.GB3261@netboy.at.omicron.at>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Richard Cochran [mailto:richardcochran@gmail.com]
> Sent: Thursday, August 23, 2012 11:56 PM
> To: Vick, Matthew
> Cc: Keller, Jacob E; Kirsher, Jeffrey T; davem@davemloft.net;
> netdev@vger.kernel.org; gospo@redhat.com; sassmann@redhat.com
> Subject: Re: [net-next 11/13] igb: Update PTP function names/variables
> and locations.
> 
> On Thu, Aug 23, 2012 at 06:44:24PM +0000, Vick, Matthew wrote:
> >
> > Isn't this discussion creeping outside the scope of this patch?
> 
> Yes, it is. I am suggesting that the driver could use improvement, but
> not by renaming functions to suit your or someone else's taste.
> Instead, you could work on the time stamping feature.
> 
> (And if, along the way, you end up renaming the functions that you
> change, then I won't complain ;)
> 
> Thanks,
> Richard

Looking over the discussions and by trying to reach consensus, I think what I will do is re-spin patch 3 that Jeff sent (Correct PTP support query from ethtool.) to V2 with your feedback and work with Jeff to send all of my patchset up together. This first group of patches is groundwork for the last two. How does this sound?

Cheers,
Matthew
