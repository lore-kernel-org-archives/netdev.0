From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 0/3] forcedeth: patches
Date: Thu, 27 Jul 2006 18:50:07 -0700
Message-ID: <20060728015007.625581647@localhost>
Cc: Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:38838 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751788AbWG1B42 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jul 2006 21:56:28 -0400
To: Ayaz Abdulla <aabdulla@nvidia.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Corrected version of forcedeth patches.
 * coding style had some extra garbage
 * add patch to use little endian annotation
 * NAPI patch could get stuck in interrupt


