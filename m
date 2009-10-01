From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] make TLLAO option for NA packets configurable
Date: Thu, 1 Oct 2009 11:14:50 -0700
Message-ID: <20091001111450.221969cc@s6510>
References: <200910011916.40908.cratiu@ixiacom.com>
	<20091001092100.14ea024b@s6510>
	<20091001.094356.95174955.davem@davemloft.net>
	<200910012108.41071.cratiu@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	opurdila@ixiacom.com
To: Cosmin Ratiu <cratiu@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:58067 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755609AbZJASPR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Oct 2009 14:15:17 -0400
In-Reply-To: <200910012108.41071.cratiu@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 1 Oct 2009 21:08:40 +0300
Cosmin Ratiu <cratiu@ixiacom.com> wrote:

> On Thursday 01 October 2009 19:43:56 David Miller wrote:
> > Using CLT_UNNUMBERED is a must these days.
> >
> > Also, please fix the prefixing of the paths in your patch.
> > See Documentation/SubmittingPatches in the kernel tree.
> 
> Here is the new variant. Please let me know what you think.
> 
> And I apologize for using [PATCH] instead of [RFC] in the subject, I don't 
> know much about netdev protocol (yet).
> 
> Cosmin.

Probably this should be a per interface property rather than per namespace.
