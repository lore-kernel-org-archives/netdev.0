From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/14] i40e: whitespace
Date: Fri,  6 Dec 2013 18:17:15 -0800
Message-ID: <1386382643-29055-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1386382643-29055-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:64593 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758146Ab3LGCR3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Dec 2013 21:17:29 -0500
In-Reply-To: <1386382643-29055-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Whitespace fixes

Change-Id: I95f4d02e4a2a92d6b6fca3ae2b7865c4b916a9bb
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_register.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_register.h b/drivers/net/ethernet/intel/i40e/i40e_register.h
index 46a2f40..2394c66 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_register.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_register.h
@@ -66,6 +66,7 @@
 #define I40E_PFPCI_VM_FLUSH_DONE 0x0009C880
 #define I40E_PFPCI_VM_FLUSH_DONE_FLUSH_DONE_SHIFT 0
 #define I40E_PFPCI_VM_FLUSH_DONE_FLUSH_DONE_MASK (0x1 << I40E_PFPCI_VM_FLUSH_DONE_FLUSH_DONE_SHIFT)
+
 #define I40E_PF_ARQBAH 0x00080180
 #define I40E_PF_ARQBAH_ARQBAH_SHIFT 0
 #define I40E_PF_ARQBAH_ARQBAH_MASK (0xFFFFFFFF << I40E_PF_ARQBAH_ARQBAH_SHIFT)
-- 
1.8.3.1
