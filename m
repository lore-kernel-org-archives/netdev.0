From: Roopa Prabhu <roprabhu@cisco.com>
Subject: [net-next-2.6 PATCH 0/2] enic: updates to version 1.4.1.9
Date: Wed, 08 Dec 2010 15:53:52 -0800
Message-ID: <20101208235340.24874.50597.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-5.cisco.com ([171.68.10.87]:29306 "EHLO
	sj-iport-5.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751872Ab0LHXxx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Dec 2010 18:53:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series implements the following enic driver updates:

01/2 - Add ndo_set_vf_mac support for enic dynamic devices
02/2 - Use VF mac set by IFLA_VF_MAC in port profile provisioning data


Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
Signed-off-by: David Wang <dwang2@cisco.com>
Signed-off-by: Christian Benvenuti <benve@cisco.com>
