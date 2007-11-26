From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 0/6] skge update (for 2.6.24)
Date: Mon, 26 Nov 2007 11:54:47 -0800
Message-ID: <20071126195447.846382144@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:38181 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753660AbXKZUDr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2007 15:03:47 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This resolves the skge problems that show up on dual ported
and fiber attached boards. These fixes have been validated by
the users that reported regressions with earlier patches.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

