From: Oliver Neukum <oneukum@suse.com>
Subject: [PATCHv2: 0 / 3] introducing the common CDC parser to other drivers
Date: Mon, 19 Oct 2015 13:48:38 +0200
Message-ID: <1445255321-13029-1-git-send-email-oneukum@suse.com>
Cc: Oliver Neukum <oneukum@suse.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	gregKH@linuxfoundation.org, linuxusb-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:45090 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750885AbbJSLuY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Oct 2015 07:50:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series introduces the common CDC parser into the CDC tty and serial
drivers. As it depends on the common parser in the netdev tree, Greg
agreed for this to go through the netdev tree.

Signed-off-by: Oliver Neukum <oneukum@suse.com>
