From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bnx2x: correction to firmware interface
Date: Tue, 03 Apr 2012 19:04:08 -0400 (EDT)
Message-ID: <20120403.190408.54610555291057345.davem@davemloft.net>
References: <1333447631-18536-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dmitry@broadcom.com, eilong@broadcom.com,
	mchan@broadcom.com, bprakash@broadcom.com
To: yuvalmin@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39380 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753519Ab2DCXEL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2012 19:04:11 -0400
In-Reply-To: <1333447631-18536-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Yuval Mintz" <yuvalmin@broadcom.com>
Date: Tue, 3 Apr 2012 13:07:11 +0300

> Commit 621b4d6 updated the bnx2x driver to a new FW version, but lacked
> a commit to a header file with changes to the firmware's interface. 
> The missing interface change causes iscsi and fcoe to misbehave with the 
> updated firmware.
> 
> Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
> Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
> CC: Michael Chan <mchan@broadcom.com>
> CC: Bhanu Prakash Gollapudi <bprakash@broadcom.com>

Applied, how far back do -stable releases need this fix?
