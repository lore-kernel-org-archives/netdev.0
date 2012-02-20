From: Roopa Prabhu <roprabhu@cisco.com>
Subject: [net-next-2.6 PATCH 0/4] enic: updates to version 2.1.1.38
Date: Mon, 20 Feb 2012 02:11:43 -0800
Message-ID: <20120220101140.5794.60233.stgit@rhel6.1>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtv-iport-4.cisco.com ([173.36.130.15]:36102 "EHLO
	mtv-iport-4.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753261Ab2BTCRy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Feb 2012 21:17:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series implements the following enic driver sriov related updates:

01/4 - enic: rename CMD_MAC_ADDR to CMD_SET_MAC_ADDR
02/4 - enic: Add new fw devcmd to set mac address of an interface
03/4 - enic: Fix ndo_set_vf_mac and ndo_set_vf_port to set/get the sriov vf's mac
04/4 - enic: Add support for fw init command on sriov vf's

Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
Signed-off-by: Christian Benvenuti <benve@cisco.com>
Signed-off-by: Sujith Sankar <ssujith@cisco.com>
