From: "Nelson, Shannon" <shannon.nelson@intel.com>
Subject: RE: [E1000-devel] [net-next v4 7/8] i40e: sysfs and debugfs
 interfaces
Date: Thu, 5 Sep 2013 01:25:47 +0000
Message-ID: <FC41C24E35F18A40888AACA1A36F3E416C61CF23@FMSMSX102.amr.corp.intel.com>
References: <1378336629-24224-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1378336629-24224-8-git-send-email-jeffrey.t.kirsher@intel.com>
 <20130904173759.7c2eec52@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: Stephen Hemminger <stephen@networkplumber.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:46877 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762784Ab3IEBZt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Sep 2013 21:25:49 -0400
In-Reply-To: <20130904173759.7c2eec52@nehalam.linuxnetplumber.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Stephen Hemminger [mailto:stephen@networkplumber.org]
> Sent: Wednesday, September 04, 2013 5:38 PM
> 

[ ... many good comments on i40e_sysfs.c ... ]

Hi Stephen,

Thanks for your comments.  Frankly, we were hoping for this kind of feedback when we posted the first version of this driver a couple of months ago, with the intent of clearing up any issues in time to get settled and accepted about now.  Yes, this is driven by business reasons that this list doesn't need to hear me whine about, but that is our reality.

We'll be happy to work with you on- or off-list over the next few days to come up with a good resolution to your concerns, and from that we can publish follow-on patches to this current submission.  We should be able to get it settled and done quickly and without too much fuss.  I won't be at Plumber's this year, but perhaps Jesse or John can get together with you and other concerned sysfs folks if needed to finalize any issues.

Will this work for you?

Thanks,
sln
