From: Jim Dykman <dykmanj@linux.vnet.ibm.com>
Subject: Re: [ANNOUNCE] Host Fabric Interface (HFI) device driver available
 on sourceforge
Date: Sun, 31 Oct 2010 15:43:14 -0400
Message-ID: <4CCDC6D2.4050207@linux.vnet.ibm.com>
References: <4CCCDE23.1090202@linux.vnet.ibm.com> <20101030.210806.232732630.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e7.ny.us.ibm.com ([32.97.182.137]:57083 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752849Ab0JaTnY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 31 Oct 2010 15:43:24 -0400
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by e7.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o9VJR4i7013843
	for <netdev@vger.kernel.org>; Sun, 31 Oct 2010 15:27:04 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o9VJhJqr1904884
	for <netdev@vger.kernel.org>; Sun, 31 Oct 2010 15:43:19 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o9VJhIK0028085
	for <netdev@vger.kernel.org>; Sun, 31 Oct 2010 15:43:18 -0400
In-Reply-To: <20101030.210806.232732630.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/31/2010 12:08 AM, David Miller wrote:
> From: Jim Dykman<dykmanj@linux.vnet.ibm.com>
> Date: Sat, 30 Oct 2010 23:10:27 -0400
>
>> The HFI network interface is the internal cluster fabric of IBM's
>> PERCS supercomputer. The device driver patch for 2.6.36, hfi-utils,
>> and an introduction to the hardware are available on the sourceforge
>> page (http://sourceforge.net/projects/hfidevicedriver). The hardware
>> design is under US export control, so we cannot release hardware
>> specs.
>
> Nobody is going to look at your code, let alone help review it
> for inclusion, if you just say "go look at this stuff on this
> sourceforge web site."
>
> You have to post the kernel patches here, one by one.

Sorry, thought I was following the instructions for large patches in 
Documentation/SubmittingPatches. It is currently one patch of about 
22000 lines, around 630k.

Most of the patch is new files, I'm figuring one file per email.
There are 2 files just under 3000 lines, 4 in the 1000-1700 line range, 
and some smaller ones. Do I need to break any of those up further?

Jim Dykman

