From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/9] New cxgb4vf network driver for Chelsio T4 Virtual
 Function NIC
Date: Tue, 29 Jun 2010 00:01:42 -0700 (PDT)
Message-ID: <20100629.000142.52193526.davem@davemloft.net>
References: <201006251507.48604.leedom@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: leedom@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47806
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753281Ab0F2HB3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jun 2010 03:01:29 -0400
In-Reply-To: <201006251507.48604.leedom@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Applied, but this submission was a mess.

First, your email client broke up long lines in the patch
with newlines, thus corrupting the patch.

Secondly, patch #3 ("cxgb4vf: Add new macros and definitions for
hardware constants") did not apply cleanly to net-next-2.6,
there were line differences.

I fixed these up, but next time I will just toss the patch
set back at you to fix up.
