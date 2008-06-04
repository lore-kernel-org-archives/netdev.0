From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH][IPROUTE2] Support device movement between network namespaces
Date: Wed, 04 Jun 2008 04:27:17 -0700
Message-ID: <m1fxrtqw2y.fsf@frodo.ebiederm.org>
References: <20080424151528.746600079@theryb.frec.bull.fr>
	<20080424151630.970357562@theryb.frec.bull.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Daniel Lezcano <dlezcano@fr.ibm.com>, netdev@vger.kernel.org
To: Benjamin Thery <benjamin.thery@bull.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:60343 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760181AbYFDLaV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2008 07:30:21 -0400
In-Reply-To: <20080424151630.970357562@theryb.frec.bull.fr> (Benjamin Thery's
	message of "Thu, 24 Apr 2008 17:15:38 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Benjamin Thery <benjamin.thery@bull.net> writes:

> Hi Stephen,
>
> I don't know if anyone has already sent you this patch for iproute2 to
> enable movement of network devices between network namespaces. 
> (Daniel Lezcano is the original author). 
>
> It applies on iproute2-2.6.25.
>
> Benjamin
>
>
> This patch adds support for the IFLA_NET_NS_PID type used to move 
> network devices between network namespaces.
>
> The syntax is: 
> ip link DEVICE netns PID
>
> PID is the pid of a process in the target network namespace.

Acked-by: "Eric W. Biederman" <ebiederm@xmission.com>

It does not look like this patch has been merged?
Is the queue just slow right now? Or is there some particular reason?

Eric
