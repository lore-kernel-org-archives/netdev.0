From: Erik Hugne <erik.hugne@ericsson.com>
Subject: [iproute2] sock_diag support for tipc?
Date: Thu, 17 Jan 2013 12:26:28 +0100
Message-ID: <20130117112628.GC27319@eerihug-hybrid.ki.sw.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: netdev@vger.kernel.org
To: shemminger@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw7.ericsson.se ([193.180.251.48]:54214 "EHLO
	mailgw7.ericsson.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754008Ab3AQLoY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2013 06:44:24 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We have plans to add SOCK_DIAG support for the TIPC protocol.
Would it be a good idea to include the userspace part of this in
iproute2/ss?
