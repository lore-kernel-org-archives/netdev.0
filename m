From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 00/11] netpoll cleanups
Date: Sat, 03 Nov 2007 11:43:14 -0700
Message-ID: <20071103184314.216145305@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Satyam Sharma <satyam@infradead.org>,
	Satyam Sharma <satyam@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:39045 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757833AbXKCXgf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Nov 2007 19:36:35 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These patches simplify netpoll by better locking,
reorganizing code etc.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

