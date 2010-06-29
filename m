From: Casey Leedom <leedom@chelsio.com>
Subject: Re: [PATCH 0/9] New cxgb4vf network driver for Chelsio T4 Virtual Function NIC
Date: Tue, 29 Jun 2010 09:04:50 -0700
Message-ID: <201006290904.50370.leedom@chelsio.com>
References: <201006251507.48604.leedom@chelsio.com> <20100629.000142.52193526.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:21839 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753389Ab0F2QMU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jun 2010 12:12:20 -0400
In-Reply-To: <20100629.000142.52193526.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| From: David Miller <davem@davemloft.net>
| Date: Tuesday, June 29, 2010 12:01 am
| 
| Applied, but this submission was a mess.
| 
| First, your email client broke up long lines in the patch
| with newlines, thus corrupting the patch.
| 
| Secondly, patch #3 ("cxgb4vf: Add new macros and definitions for
| hardware constants") did not apply cleanly to net-next-2.6,
| there were line differences.
| 
| I fixed these up, but next time I will just toss the patch
| set back at you to fix up.

  Thank you and I'm sorry for the mess. (sigh) I'm using the Kubuntu supplied 
email client and I mistakenly assumed that its "Insert File" action would do the 
right job.  I'll just use Thunderbird from now on.

  Odd that patch #3 didn't apply cleanly.  I'll do a "pull" and verify correct 
operation.

Casey
