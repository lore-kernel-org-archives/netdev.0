From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: Future of the Wimedia LLC Protocol (WLP) subsystem/drivers
Date: Wed, 20 Oct 2010 09:15:41 -0700
Message-ID: <20101020091541.ec00fe96.randy.dunlap@oracle.com>
References: <4CBDC7B7.5070108@csr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gregkh <greg@kroah.com>
To: David Vrabel <david.vrabel@csr.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:56831 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752460Ab0JTQP6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Oct 2010 12:15:58 -0400
In-Reply-To: <4CBDC7B7.5070108@csr.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 19 Oct 2010 17:30:47 +0100 David Vrabel wrote:

> Hi,
> 
> I've have been nominally the maintainer of the Wimedia LLC Protocol
> (WLP) subsystem and driver since it was originally submitted.  I am no
> longer in a position to even pretend to be a maintainer.
> 
> The only usable hardware was an Intel i1480 devices with beta firmware
> that was never released as a product.  Intel have since sold all there
> UWB/WLP IP and I see little prospect of there ever being hardware
> commercially available for WLP.
> 
> Here are a number of options:
> 
> 1. Someone else maintains it.  Any volunteers?
> 
> 2. It gets labelled as Orphaned in MAINTAINERS.
> 
> 3. It gets moved to staging.
> 
> 4, It gets removed.
> 
> If no one says anything I'll submit a patch to Linus to mark it as Orphaned.

I'd say either 3 or 4.

It could go to staging on it way to removal, but that's not really necessary.


cc: gregkh


---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
