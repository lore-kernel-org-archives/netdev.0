From: "Brown, Aaron F" <aaron.f.brown@intel.com>
Subject: RE: [Intel-wired-lan] [next] igb: allow setting MAC address on i211
 using a device tree blob V5
Date: Tue, 1 Mar 2016 23:23:23 +0000
Message-ID: <309B89C4C689E141A5FF6A0C5FB2118B81EA7AB2@ORSMSX101.amr.corp.intel.com>
References: <56C5A6BC.6030708@gmail.com>
 <309B89C4C689E141A5FF6A0C5FB2118B81EA731A@ORSMSX101.amr.corp.intel.com>
 <DC20A3D2-95E2-420B-911D-C6AC02338227@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: John Holland <jotihojr@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:40070 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752425AbcCAXXZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 18:23:25 -0500
In-Reply-To: <DC20A3D2-95E2-420B-911D-C6AC02338227@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: John Holland [mailto:jotihojr@gmail.com]
> Sent: Monday, February 29, 2016 10:56 PM
> To: Brown, Aaron F <aaron.f.brown@intel.com>
> Cc: intel-wired-lan@lists.osuosl.org; netdev@vger.kernel.org
> Subject: Re: [Intel-wired-lan] [next] igb: allow setting MAC address on i211
> using a device tree blob V5
> 
> On Mar 1, 2016, at 03:52, Brown, Aaron F <aaron.f.brown@intel.com>
> wrote:
> 
> > This throws a few checkpatch warnings, but I won't withhold my tested by
> for these:
> >
> > total: 0 errors, 2 warnings, 0 checks, 21 lines checked
> >
> > Your patch has style problems, please review.
> >
> > NOTE: If any of the errors are false positives, please report
> >      them to the maintainer, see CHECKPATCH in MAINTAINERS.
> > u1463:[0]/usr/src/kernels/next-queue>
> 
> Thanks for testing...
> 
> Do you require me to reformat the patch text? And won't that break the link?

Unless Jeff Kirsher wants you to resubmit it for the space between your name and email address I don't think resubmitting should be necessary.  Yes, breaking the URL up would break the URL and for that reason I think it is appropriate to ignore that (Possible unwrapped commit description) warning.

Thanks,
Aaron
> 
> John
