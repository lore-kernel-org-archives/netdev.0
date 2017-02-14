From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH V4 2/2] qedf: Add QLogic FastLinQ offload FCoE driver
 framework.
Date: Tue, 14 Feb 2017 10:13:08 +0800
Message-ID: <201702141025.qINpoySA%fengguang.wu@intel.com>
References: <1487013421-27006-3-git-send-email-chad.dupuis@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, martin.petersen@oracle.com,
        linux-scsi@vger.kernel.org, fcoe-devel@open-fcoe.org,
        netdev@vger.kernel.org, yuval.mintz@cavium.com,
        QLogic-Storage-Upstream@cavium.com
To: "Dupuis, Chad" <chad.dupuis@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:14671 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751583AbdBNCNP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 13 Feb 2017 21:13:15 -0500
Content-Disposition: inline
In-Reply-To: <1487013421-27006-3-git-send-email-chad.dupuis@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Chad,

[auto build test WARNING on net-next/master]

url:    https://github.com/0day-ci/linux/commits/Dupuis-Chad/qed-Add-support-for-hardware-offloaded-FCoE/20170214-040339


coccinelle warnings: (new ones prefixed by >>)

>> drivers/scsi/qedf/qedf_main.c:2742:2-7: WARNING: NULL check before freeing functions like kfree, debugfs_remove, debugfs_remove_recursive or usb_free_urb is not needed. Maybe consider reorganizing relevant code to avoid passing NULL values.

Please review and possibly fold the followup patch.

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
