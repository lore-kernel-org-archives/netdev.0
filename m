From: Scott Feldman <scofeldm@cisco.com>
Subject: [PATCH 0/5] enic: updates
Date: Fri, 21 Nov 2008 16:33:51 -0800
Message-ID: <20081122003219.15540.26759.stgit@palito_client100.nuovasystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-2.cisco.com ([171.71.176.71]:40777 "EHLO
	sj-iport-2.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754532AbYKVAlZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 19:41:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff,

enic driver updates:

	[1/5] enable ethtool LRO support to fix bridge compat
	[2/5] update driver/firmware API
	[3/5] mask reserved bits in CQ descr
	[4/5] Move wmb() closer to writing of posted_index
	[5/5] misc items

-scott

Signed-off-by: Scott Feldman <scofeldm@cisco.com>
