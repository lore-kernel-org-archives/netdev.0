From: Stephen Hemminger <shemming@brocade.com>
Subject: Re: iproute2 compatibility
Date: Thu, 1 Oct 2015 15:02:53 -0700
Message-ID: <20151001150253.3c1d695f@urahara>
References: <998e657b10fc41d286bf372de59969b3@HQ1WP-EXMB11.corp.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ani Sinha <ani@arista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:19629 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750823AbbJAWCr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2015 18:02:47 -0400
In-Reply-To: <998e657b10fc41d286bf372de59969b3@HQ1WP-EXMB11.corp.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 1 Oct 2015 20:06:00 +0000
Ani Sinha <ani@arista.com> wrote:

> Hi Stephen :
> 
> I was looking around but could not find clear evidence that a later
> version of iproute2 is compatible with an older kernel. Specifically,
> we are wondering if iproute2 v 3.6 is compatible with linux kernel
> 3.4. Highly appreciate any pointers on this.
> 
> thanks
> ani

Yes. iproute2 is supposed to compatible with older kernels.
Obviously, if you try to use some new feature on older kernel, an error
will result. 
