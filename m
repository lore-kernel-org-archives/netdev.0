From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [net-next 11/13] igb: Update PTP function names/variables and
 locations.
Date: Fri, 24 Aug 2012 08:55:55 +0200
Message-ID: <20120824065554.GB3261@netboy.at.omicron.at>
References: <1345715813-20757-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1345715813-20757-12-git-send-email-jeffrey.t.kirsher@intel.com>
 <20120823111622.GC2238@netboy.at.omicron.at>
 <06DFBC1E25D8024DB214DC7F41A3CD34488DD079@ORSMSX101.amr.corp.intel.com>
 <20120823175335.GB2192@netboy.at.omicron.at>
 <02874ECE860811409154E81DA85FBB5807857EEA@ORSMSX105.amr.corp.intel.com>
 <20120823181117.GD2192@netboy.at.omicron.at>
 <06DFBC1E25D8024DB214DC7F41A3CD34488DD379@ORSMSX101.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Keller, Jacob E" <jacob.e.keller@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: "Vick, Matthew" <matthew.vick@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:52003 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753243Ab2HXG4H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2012 02:56:07 -0400
Received: by weyx8 with SMTP id x8so842870wey.19
        for <netdev@vger.kernel.org>; Thu, 23 Aug 2012 23:56:05 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <06DFBC1E25D8024DB214DC7F41A3CD34488DD379@ORSMSX101.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 23, 2012 at 06:44:24PM +0000, Vick, Matthew wrote:
> 
> Isn't this discussion creeping outside the scope of this patch?

Yes, it is. I am suggesting that the driver could use improvement, but
not by renaming functions to suit your or someone else's taste.
Instead, you could work on the time stamping feature.

(And if, along the way, you end up renaming the functions that you
change, then I won't complain ;)

Thanks,
Richard
