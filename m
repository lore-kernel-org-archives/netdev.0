From: Oliver Neukum <oneukum@suse.com>
Subject: [PATCH v2 0/2]fixes to kaweth in response to Umap2 testing
Date: Wed, 17 Aug 2016 15:51:54 +0200
Message-ID: <1471441916-19656-1-git-send-email-oneukum@suse.com>
To: linux-usb@vger.kernel.org, stern@rowland.harvard.edu,
	netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:49941 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751802AbcHQNyp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Aug 2016 09:54:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These patches fix an oops in firmware downloading and an oops due
to a memory allocation failure
