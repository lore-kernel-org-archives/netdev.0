From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] iproute2: enable setting rto_min, rtt and rttvar in
 tc-esque units
Date: Wed, 19 Sep 2007 14:51:33 -0700
Message-ID: <20070919145133.7aff0a5b@freepuppy.rosehill.hemminger.net>
References: <200709182015.NAA25590@tardy.cup.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:52300 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752365AbXISVvq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2007 17:51:46 -0400
In-Reply-To: <200709182015.NAA25590@tardy.cup.hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 18 Sep 2007 13:15:26 -0700 (PDT)
Rick Jones <rick.jones2@hp.com> wrote:

> Enable users of ip to specify the times for rtt, rttvar and rto_min
> in human-friendly terms a la "tc" while maintaining backwards 
> compatability with the previous "raw" mechanism.  Builds upon
> David Miller's uncommited patch to set rto_min.
> 
> Signed-off-by: Rick Jones <rick.jones2@hp.com>

Thanks, I'll put it in the 2.6.24 version of iproute2 (assuming dave
takes the rto_min patch).
