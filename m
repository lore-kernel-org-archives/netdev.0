From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC NET_SCHED 00/03]: ktime + nano-second clock resolution for
 packet schedulers
Date: Mon, 05 Mar 2007 20:27:10 +0100
Message-ID: <45EC6F0E.2030908@trash.net>
References: <20070304190439.21142.66736.sendpatchset@localhost.localdomain>	<20070304.162557.112625456.davem@davemloft.net>	<45EC5682.6000406@trash.net> <20070305110928.25ce596c@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:53854 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932283AbXCET12 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Mar 2007 14:27:28 -0500
In-Reply-To: <20070305110928.25ce596c@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Don't bother changing netem. I have a version that uses hrtimer's
> and doesn't use PSCHED() clock source anymore.

Me too :) I'm going to send it with my other patches soon, if you
don't like it we can still drop it.
