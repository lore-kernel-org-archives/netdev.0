From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ptp: restore the makefile for building the test
 program.
Date: Fri, 24 Oct 2014 16:08:13 -0400 (EDT)
Message-ID: <20141024.160813.2166418625625734986.davem@davemloft.net>
References: <edb4b32ca0326b648d905620d95297cef5ed9391.1414006463.git.rcochran@linutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pefoley2@pefoley.com
To: richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52777 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752109AbaJXUIR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Oct 2014 16:08:17 -0400
In-Reply-To: <edb4b32ca0326b648d905620d95297cef5ed9391.1414006463.git.rcochran@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Cochran <richardcochran@gmail.com>
Date: Wed, 22 Oct 2014 21:35:15 +0200

> This patch brings back the makefile called testptp.mk which was removed
> in commit adb19fb66eee (Documentation: add makefiles for more targets).
> 
> While the idea of that commit was to improve build coverage of the
> examples, the new Makefile is unable to cross compile the testptp program.
> In contrast, the deleted makefile was able to do this just fine.
> 
> This patch fixes the regression by restoring the original makefile.
> 
> Signed-off-by: Richard Cochran <richardcochran@gmail.com>

Applied, thanks Richard.
