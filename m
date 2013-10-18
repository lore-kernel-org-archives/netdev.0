From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH net-next v3 3/9] static_key: WARN on usage before
 jump_label_init was called
Date: Fri, 18 Oct 2013 02:50:57 +0200
Message-ID: <20131018005057.GL2592@two.firstfloor.org>
References: <1381987923-1524-1-git-send-email-hannes@stressinduktion.org>
 <1381987923-1524-4-git-send-email-hannes@stressinduktion.org>
 <20131017171940.173bab09@gandalf.local.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Andi Kleen <andi@firstfloor.org>
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([193.170.194.197]:55016 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753810Ab3JRAvA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Oct 2013 20:51:00 -0400
Content-Disposition: inline
In-Reply-To: <20131017171940.173bab09@gandalf.local.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 17, 2013 at 05:19:40PM -0400, Steven Rostedt wrote:
> On Thu, 17 Oct 2013 07:31:57 +0200
> Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:
> 
> > Based on a patch from Andi Kleen.
> 
> I'm fine with the patch, but the change log needs a lot more work.
> Like, why is this needed?  I know, but does anyone else?

Or just merge the orininal patch. While being less verbose
in the warning it had a full changelog.

-Andi
