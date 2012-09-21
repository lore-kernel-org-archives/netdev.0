From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next 3/3] ptp: derive the device name from the
 parent device
Date: Fri, 21 Sep 2012 20:11:16 +0200
Message-ID: <20120921181115.GE6129@netboy.at.omicron.at>
References: <cover.1348245523.git.richardcochran@gmail.com>
 <9f2ed4a62d52182eeab86ad3dca7f6feeb68368a.1348245523.git.richardcochran@gmail.com>
 <1348247965.2521.11.camel@bwh-desktop.uk.solarflarecom.com>
 <20120921173709.GB6129@netboy.at.omicron.at>
 <02874ECE860811409154E81DA85FBB5818BFF5B4@ORSMSX105.amr.corp.intel.com>
 <1348249258.2521.25.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Keller, Jacob E" <jacob.e.keller@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	"Vick, Matthew" <matthew.vick@intel.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:52483 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756394Ab2IUSL1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2012 14:11:27 -0400
Received: by wgbdr13 with SMTP id dr13so1637488wgb.1
        for <netdev@vger.kernel.org>; Fri, 21 Sep 2012 11:11:26 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1348249258.2521.25.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 21, 2012 at 06:40:58PM +0100, Ben Hutchings wrote:
> On Fri, 2012-09-21 at 17:39 +0000, Keller, Jacob E wrote:
> > With the device, it is possible to lookup the driver.
> 
> For PCI devices, yes.  But there is really no guarantee that device
> names (as in dev_name()) are globally unique either.

Ben, I tried to implement your suggestion from September 7th.
Don't you like it, or did I misunderstand you?

Thanks,
Richard
