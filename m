From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [net-next] iproute2: Add new command to IP link to
 enable/disable VF spoof check
Date: Thu, 17 Nov 2011 16:45:28 -0800
Message-ID: <20111117164528.293ec0ea@nehalam.linuxnetplumber.net>
References: <1316938998-29855-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<4EC59B34.4080501@intel.com>
	<20111117164044.21b916dd@nehalam.linuxnetplumber.net>
	<4EC5AA1B.4040009@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>
To: Greg Rose <gregory.v.rose@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:55376 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755335Ab1KRApb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Nov 2011 19:45:31 -0500
In-Reply-To: <4EC5AA1B.4040009@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 17 Nov 2011 16:43:07 -0800
Greg Rose <gregory.v.rose@intel.com> wrote:

> On 11/17/2011 4:40 PM, Stephen Hemminger wrote:
> > On Thu, 17 Nov 2011 15:39:32 -0800
> > Greg Rose<gregory.v.rose@intel.com>  wrote:
> >
> >>
> >>
> >> On 9/25/2011 1:23 AM, Jeff Kirsher wrote:
> >>> From: Greg Rose<gregory.v.rose@intel.com>
> >>>
> >>> Add IP link command parsing for VF spoof checking enable/disable
> >>>
> >>> Signed-off-by: Greg Rose<gregory.v.rose@intel.com>
> >>> Signed-off-by: Jeff Kirsher<jeffrey.t.kirsher@intel.com>
> >
> > I am limiting patches at this point to those that will build against 3.0.
> > The 3.1 version of iproute2 has not been released because kernel.org tool
> > to do the release is still in beta (kup), and they are working on it.
> >
> > After 3.1 version of iproute2 is released, any fixes that require stuff
> > from 3.2 will go in.
> 
> Great, sounds good.
> 
> Would you prefer that I Jeff (Kirsher) and I repost the patch at that time?

not required, if they show up in patchwork
