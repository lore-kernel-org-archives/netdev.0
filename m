From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Subject: Re: Strange soft lockup detected message (looks like spin_lock bug in pcnet32)
Date: Mon, 7 May 2007 13:45:11 -0400
Message-ID: <20070507174511.GL8751@csclub.uwaterloo.ca>
References: <20070504143326.GD24769@slug> <20070504151934.GA8754@csclub.uwaterloo.ca> <20070504153438.GE24769@slug> <20070504154009.GE8751@csclub.uwaterloo.ca> <20070504174456.GC8753@csclub.uwaterloo.ca> <20070504175017.GD8753@csclub.uwaterloo.ca> <20070504182433.GA11595@verizon.net> <20070504190236.GE8753@csclub.uwaterloo.ca> <20070507140807.GF8753@csclub.uwaterloo.ca> <20070507144837.GA30865@slug>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Don Fry <pcnet32@verizon.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Frederik Deweerdt <deweerdt@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caffeine.uwaterloo.ca ([129.97.134.17]:35132 "EHLO
	caffeine.csclub.uwaterloo.ca" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754096AbXEGRpM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 May 2007 13:45:12 -0400
Content-Disposition: inline
In-Reply-To: <20070507144837.GA30865@slug>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 07, 2007 at 04:48:37PM +0200, Frederik Deweerdt wrote:
> Can you try running on another Geode LX system, just to rule out a
> hardware problem on you board?

Hmm, I thought I saw it on two systems already, but I should go try that
again.

--
Len Sorensen
