From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Subject: Re: Strange soft lockup detected message (looks like spin_lock bug in pcnet32)
Date: Fri, 4 May 2007 11:40:09 -0400
Message-ID: <20070504154009.GE8751@csclub.uwaterloo.ca>
References: <20070503203143.GA8753@csclub.uwaterloo.ca> <20070504141024.GB8753@csclub.uwaterloo.ca> <20070504143326.GD24769@slug> <20070504151934.GA8754@csclub.uwaterloo.ca> <20070504153438.GE24769@slug>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Frederik Deweerdt <deweerdt@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caffeine.uwaterloo.ca ([129.97.134.17]:40172 "EHLO
	caffeine.csclub.uwaterloo.ca" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1030792AbXEDPkK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2007 11:40:10 -0400
Content-Disposition: inline
In-Reply-To: <20070504153438.GE24769@slug>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 04, 2007 at 05:34:38PM +0200, Frederik Deweerdt wrote:
> For the "what" part, see Documentation/lockdep-design.txt. You'll enable
> it by with SPINLOCK_DEBUG, indeed.

Well I hope to see it hit the BUG again soon then to see what it has to
say.

--
Len Sorensen
