From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH 0/16] Spidernet RX Misc cleanups and fixes
Date: Wed, 6 Dec 2006 16:32:23 -0600
Message-ID: <20061206223223.GH17931@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	James K Lewis <jklewis@us.ibm.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Geoff Levand <geoffrey.levand@am.sony.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:60692 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S937748AbWLFWc0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Dec 2006 17:32:26 -0500
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e33.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id kB6MWP1E010517
	for <netdev@vger.kernel.org>; Wed, 6 Dec 2006 17:32:25 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kB6MWP1L398586
	for <netdev@vger.kernel.org>; Wed, 6 Dec 2006 15:32:25 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kB6MWN6m009187
	for <netdev@vger.kernel.org>; Wed, 6 Dec 2006 15:32:24 -0700
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Andrew, 

Please apply and forward upstream. This series of 16 small patches 
consist of mostly of various cleanups, a few fixes, and a clarification
of the flow of the RX side of the spidernet ethernet driver.  The 
first patch, though, is a resubmit of an old patch.

--linas
