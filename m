From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH] sfc fix for 2.6.27
Date: Mon, 9 Jun 2008 19:24:29 +0100
Message-ID: <20080609182428.GI11300@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:60455 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752762AbYFISeg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jun 2008 14:34:36 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff,

Please add the following patch to your changes for 2.6.27.

Ben.

Ben Hutchings (1):
  sfc: I2C adapter initialisation fixes

 drivers/net/sfc/falcon.c |   12 +++---------
 1 files changed, 3 insertions(+), 9 deletions(-)
