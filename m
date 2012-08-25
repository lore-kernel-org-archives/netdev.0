From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [net-next 11/13] igb: Update PTP function names/variables and
 locations.
Date: Sat, 25 Aug 2012 07:48:46 +0200
Message-ID: <20120825054846.GA2233@netboy.at.omicron.at>
References: <1345715813-20757-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1345715813-20757-12-git-send-email-jeffrey.t.kirsher@intel.com>
 <20120823111622.GC2238@netboy.at.omicron.at>
 <06DFBC1E25D8024DB214DC7F41A3CD34488DD079@ORSMSX101.amr.corp.intel.com>
 <20120823175335.GB2192@netboy.at.omicron.at>
 <02874ECE860811409154E81DA85FBB5807857EEA@ORSMSX105.amr.corp.intel.com>
 <20120823181117.GD2192@netboy.at.omicron.at>
 <06DFBC1E25D8024DB214DC7F41A3CD34488DD379@ORSMSX101.amr.corp.intel.com>
 <20120824065554.GB3261@netboy.at.omicron.at>
 <06DFBC1E25D8024DB214DC7F41A3CD34488DDE99@ORSMSX101.amr.corp.intel.com>
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
Received: from mail-wg0-f44.google.com ([74.125.82.44]:46585 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750788Ab2HYFs6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Aug 2012 01:48:58 -0400
Received: by wgbdr13 with SMTP id dr13so2039920wgb.1
        for <netdev@vger.kernel.org>; Fri, 24 Aug 2012 22:48:56 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <06DFBC1E25D8024DB214DC7F41A3CD34488DDE99@ORSMSX101.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 24, 2012 at 03:52:30PM +0000, Vick, Matthew wrote:
> 
> Looking over the discussions and by trying to reach consensus, I think what I will do is re-spin patch 3 that Jeff sent (Correct PTP support query from ethtool.) to V2 with your feedback and work with Jeff to send all of my patchset up together. This first group of patches is groundwork for the last two. How does this sound?

Sound good to me.

BTW, if you have some bug fixes coming (like ifup/ifdown), please put
them *before* any other renaming/refactoring. In that way, the bug fix
can do directly to 3.5 stable, too.

Thanks,
Richard
