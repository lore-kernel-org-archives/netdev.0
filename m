From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 0/3] qla3xxx checksum related patches
Date: Wed, 30 May 2007 14:23:16 -0700
Message-ID: <20070530212316.407169588@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>, linux-driver@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([207.189.120.13]:53968 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757987AbXE3ViI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2007 17:38:08 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Found while looking at drivers that are doing NETIF_F_HW_CSUM
incorrectly.

The first is a bug fix. Second is cleanup, Third is an enhancement.
-- 
Stephen Hemminger <shemminger@linux-foundation.org>

