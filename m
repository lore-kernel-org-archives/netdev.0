From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: [net-next] iproute2: Add new command to IP link to
 enable/disable VF spoof check
Date: Mon, 26 Sep 2011 09:21:48 -0700
Message-ID: <43F901BD926A4E43B106BF17856F0755019C519385@orsmsx508.amr.corp.intel.com>
References: <1316938998-29855-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <20110925102353.602d239b@s6510.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>
To: Stephen Hemminger <shemminger@vyatta.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:22742 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751766Ab1IZQVt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2011 12:21:49 -0400
In-Reply-To: <20110925102353.602d239b@s6510.linuxnetplumber.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Stephen Hemminger [mailto:shemminger@vyatta.com]
> Sent: Sunday, September 25, 2011 10:24 AM
> To: Kirsher, Jeffrey T
> Cc: Rose, Gregory V; davem@davemloft.net; netdev@vger.kernel.org;
> gospo@redhat.com
> Subject: Re: [net-next] iproute2: Add new command to IP link to
> enable/disable VF spoof check
> 
> On Sun, 25 Sep 2011 01:23:18 -0700
> Jeff Kirsher <jeffrey.t.kirsher@intel.com> wrote:
> 
> > From: Greg Rose <gregory.v.rose@intel.com>
> >
> > Add IP link command parsing for VF spoof checking enable/disable
> >
> > Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
> > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> 
> See my comments about ABI compatibility. Can't just grow size of
> structure.
> Need to have new version of iproute work with older kernels.

In this case I have no idea how to proceed.  I'll go back and stare at it some more.

- Greg
