From: Ira Snyder <iws@ovro.caltech.edu>
Subject: Re: [PATCH RFC v2] net: add PCINet driver
Date: Wed, 29 Oct 2008 14:13:12 -0700
Message-ID: <20081029211312.GJ12879@ovro.caltech.edu>
References: <20081029202027.GH12879@ovro.caltech.edu> <20081029132506.55b93555@extreme> <20081029205002.GI12879@ovro.caltech.edu> <4908CD96.300@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org, linux-kernel@vger.kernel.org
To: Scott Wood <scottwood@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ovro.ovro.caltech.edu ([192.100.16.2]:56926 "EHLO
	ovro.ovro.caltech.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753519AbYJ2VNN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 17:13:13 -0400
Content-Disposition: inline
In-Reply-To: <4908CD96.300@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 29, 2008 at 03:54:46PM -0500, Scott Wood wrote:
> Ira Snyder wrote:
>> I know about this. I was following the example set forth in
>> drivers/net/fs_enet. 
>
> I recommend against that. :-)

Great, now you tell me :)

I'll go ahead change the typedef to a struct. Hopefully some of the
other inspiration I took wasn't too bad. I'm totally open to suggestions
on improvements for this driver.

Ira
