From: Yuval Mintz <yuvalmin@broadcom.com>
Subject: [PATCH net-next 0/9] bnx2x: Enhancements & semantic changes series
Date: Wed, 12 Feb 2014 18:19:48 +0200
Message-ID: <1392221997-25525-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ariele@broadcom.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:2686 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752631AbaBLQUO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 11:20:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This patch series contains several semantic (or mostly semantic) patches,
as well as adding support for packet aggregations on the receive path
of windows VMs and updating bnx2x to the new FW recently accepted upstream.

Please consider applying these patches to `net-next'.

(This is a repost as net-next was still closed when this was previously
sent)

Thanks,
Yuval Mintz
