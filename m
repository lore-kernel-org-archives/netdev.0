From: "Fujinaka, Todd" <todd.fujinaka@intel.com>
Subject: RE: igbvf warning on 3.14.x
Date: Tue, 26 Aug 2014 15:25:59 +0000
Message-ID: <9B4A1B1917080E46B64F07F2989DADD6533D2F95@ORSMSX114.amr.corp.intel.com>
References: <20140815131426.GA4638@gandi.net>
 <1408109225.2391.30.camel@jtkirshe-mobl> <20140826073613.GH8801@gandi.net>
 <9BBC4E0CF881AA4299206E2E1412B6264FBD7D4B@ORSMSX102.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	e1000-devel <e1000-devel@lists.sourceforge.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: "Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	William Dauchy <william@gandi.net>,
	"Williams, Mitch A" <mitch.a.williams@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:7775 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751551AbaHZP0B convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2014 11:26:01 -0400
In-Reply-To: <9BBC4E0CF881AA4299206E2E1412B6264FBD7D4B@ORSMSX102.amr.corp.intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry, I forgot about this one. And trimming replies on e1000-devel isn't going to help much because we're forced to use outlook here and the threading is abysmal.

Can you please send clear repro steps and I'll submit it to our lab for repro. We'll need what equipment you're running (on both sides of the link), the kind of traffic you're running, the OS & kernel you're running, etc. It might be easier to file a bug on sourceforge if you're able to do that.

Thanks.

Todd Fujinaka
Software Application Engineer
Networking Division (ND)
Intel Corporation
todd.fujinaka@intel.com
(503) 712-4565

-----Original Message-----
From: Wyborny, Carolyn 
Sent: Tuesday, August 26, 2014 8:18 AM
To: William Dauchy; Williams, Mitch A; Fujinaka, Todd
Cc: netdev@vger.kernel.org; e1000-devel; Kirsher, Jeffrey T
Subject: RE: igbvf warning on 3.14.x

Adding Todd Fujinaka, who is customer support for igbvf.  I'll assist if need be.

Thanks,

Carolyn

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
> On Behalf Of William Dauchy
> Sent: Tuesday, August 26, 2014 12:36 AM
> To: Wyborny, Carolyn; Williams, Mitch A
> Cc: William Dauchy; netdev@vger.kernel.org; e1000-devel; Kirsher, Jeffrey T
> Subject: Re: igbvf warning on 3.14.x
> 
> Hi,
> 
> On Aug15 06:27, Jeff Kirsher wrote:
> > Adding Carolyn (igb maintainer) and e1000-devel mailing list...
> 
> any chance to get some feedback on this trace?
> 
> Thanks,
> --
> William
