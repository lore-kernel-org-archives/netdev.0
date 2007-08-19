From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: Marvell 88E8056 gigabit ethernet controller
Date: Sun, 19 Aug 2007 11:34:00 -0700
Message-ID: <20070819113400.12f5570c@localhost>
References: <20070818121714.GA28247@1wt.eu>
	<283388.84897.qm@web38905.mail.mud.yahoo.com>
	<20070819093221.4d3291e9@freepuppy.rosehill.hemminger.net>
	<2456F7EB-000C-4B71-B002-64340DD17BA8@linuxmontreal.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Kevin E <kevin360@yahoo.com>, Willy Tarreau <w@1wt.eu>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Eric Preston <developer@linuxmontreal.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:60030 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754737AbXHSSe1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Aug 2007 14:34:27 -0400
In-Reply-To: <2456F7EB-000C-4B71-B002-64340DD17BA8@linuxmontreal.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The driver prints some chip version info at startup, that might
be helpful in disambiguating good/bad versions:

	dmesg | grep sky2
