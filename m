From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH] sfc fix for 2.6.26
Date: Mon, 9 Jun 2008 19:27:46 +0100
Message-ID: <20080609182745.GK11300@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:60455 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752818AbYFISei (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jun 2008 14:34:38 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff,

Please apply the following patch and send upstream for 2.6.26.

Ben.

Steve Hodgson (1):
  sfc: Recover from RX queue flush failure

 drivers/net/sfc/falcon.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
