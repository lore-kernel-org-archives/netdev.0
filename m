From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [ethtool] ethtool: Correct register dump offsets for Intel
 82575 chipsets.
Date: Thu, 12 Jan 2012 14:08:04 +0000
Message-ID: <1326377284.2819.7.camel@deadeye>
References: <1324636371-5402-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1326373862.2709.63.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Vick, Matthew" <matthew.vick@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:7540 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753525Ab2ALOIL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2012 09:08:11 -0500
In-Reply-To: <1326373862.2709.63.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-01-12 at 05:11 -0800, Jeff Kirsher wrote:
> On Fri, 2011-12-23 at 02:32 -0800, Kirsher, Jeffrey T wrote:
> > From: Matthew Vick <matthew.vick@intel.com>
> > 
> > When support was added to dump the registers on 82575 chipset devices,
> > six register offsets (receive/transmit desc length, head, and tail)
> > were incorrectly mapped. This patch remaps the offsets to the correct
> > registers.
[...]
> Ben, what is the status of this patch?

The status is 'arrived just as I went on vacation, and forgotten'.

I'll be sure to apply this before releasing ethtool 3.2.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
