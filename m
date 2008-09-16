From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 0/5][RFC]qlge: New Qlogic 10Gb Ethernet Driver
Date: Tue, 16 Sep 2008 11:52:06 -0700
Message-ID: <20080916185206.GA26395@susedev.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com,
	ron.mercer@qlogic.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:17508 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754386AbYIPSxL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2008 14:53:11 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff,

The following patches are for further RFC for the Qlogic 10Gb driver.

I believe this address all outstanding issues from RFC.

1) Get rid of millisecond register waits during open.
2) Implemented flash reading for MAC address.
3) Clean up error path for open() and close().
4) Add Ron Mercer as maintainer.
5) Get rid of all debug junk.
6) Added ethtool ops get_settings() and get_link().
7) Clean up and complete mgmnt port xface file qlge_mpi.c.


Regards,
Ron Mercer
Qlogic Corporation

