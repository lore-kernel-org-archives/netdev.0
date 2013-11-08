From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [ethtool] ethtool: ixgbe DCB registers dump for 82599 and x540
Date: Fri, 8 Nov 2013 16:46:45 +0000
Message-ID: <1383929205.3802.22.camel@bwh-desktop.uk.level5networks.com>
References: <1380787887-6878-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1383912090.2365.27.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Leonardo Potenza <leonardo.potenza@intel.com>,
	<netdev@vger.kernel.org>, <gospo@redhat.com>,
	<sassmann@redhat.com>, Maryam Tahhan <maryam.tahhan@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:17055 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757482Ab3KHQqu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Nov 2013 11:46:50 -0500
In-Reply-To: <1383912090.2365.27.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-11-08 at 04:01 -0800, Jeff Kirsher wrote:
> On Thu, 2013-10-03 at 01:11 -0700, Jeff Kirsher wrote:
> > From: Leonardo Potenza <leonardo.potenza@intel.com>
> > 
> > Added support for DCB registers dump using ethtool -d option both for
> > 82599 and x540 ethernet controllers
> > 
> > Signed-off-by: Leonardo Potenza <leonardo.potenza@intel.com>
> > Signed-off-by: Maryam Tahhan <maryam.tahhan@intel.com>
> > Acked-by: John Fastabend <john.r.fastabend@intel.com>
> > Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
> > Tested-by: Jack Morgan <jack.morgan@intel.com>
> > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > ---
> >  ixgbe.c | 154
> > ++++++++++++++++++++++++++++++++++++++++++++++++++++------------
> >  1 file changed, 125 insertions(+), 29 deletions(-)
> 
> Ben-
> I see you released 3.12 and I do not see this patch in your tree.  I
> sent it originally on October 3rd, do need me to resend it?

Sorry, I overlooked that and will reply in a moment.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
