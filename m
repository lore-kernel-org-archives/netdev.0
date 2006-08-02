From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 0/6] htb:  cleanup
Date: Wed, 2 Aug 2006 12:56:36 -0700
Message-ID: <20060802125636.3028ba91@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lartc@mailman.ds9a.nl
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:48333 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932268AbWHBWML (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2006 18:12:11 -0400
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The HTB scheduler code is a mess, this patch set does some basic
house cleaning.  The first four should cause no code change, but the
last two need more testing.

-- 
Stephen Hemminger <shemminger@osdl.org>
"And in the Packet there writ down that doome"
