From: Roopa Prabhu <roprabhu@cisco.com>
Subject: [net-next-2.6 PATCH 0/4] enic: updates to version 2.1.1.31
Date: Wed, 18 Jan 2012 06:23:50 -0800
Message-ID: <20120118142336.7877.67031.stgit@rhel6.1>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtv-iport-3.cisco.com ([173.36.130.14]:49555 "EHLO
	mtv-iport-3.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751506Ab2ARGkF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2012 01:40:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series implements the following enic driver sriov related updates:

01/4 - enic: This patch adds pci id 0x71 for SRIOV VF's
02/4 - enic: Add sriov vf device id checks in port profile code
03/4 - enic: rearrange some of the sriov port profile code
04/4 - enic: fix location of vnic dev unregister in enic_probe cleanup code

Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
Signed-off-by: Christian Benvenuti <benve@cisco.com>
Signed-off-by: Sujith Sankar <ssujith@cisco.com>
