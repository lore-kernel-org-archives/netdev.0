From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: net-2.6.24 won't power off
Date: Wed, 26 Sep 2007 20:06:17 -0700
Message-ID: <20070926200617.78cf8b73@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:53552 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751501AbXI0DGV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Sep 2007 23:06:21 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Shutdown no longer powers off, something changed.  2.6.23-rc8 works
fine, but net-2.6.24 gets to shutting off the disks and never finishes.
Any ideas before I go on a bisect hunt?


-- 
Stephen Hemminger <shemminger@linux-foundation.org>
