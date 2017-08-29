From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnxt_en: add a dummy definition for
 bnxt_vf_rep_get_fid()
Date: Tue, 29 Aug 2017 09:28:57 -0700 (PDT)
Message-ID: <20170829.092857.571536467798292453.davem@davemloft.net>
References: <1503987303-12392-1-git-send-email-sathya.perla@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathya.perla@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34666 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751186AbdH2Q3A (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 12:29:00 -0400
In-Reply-To: <1503987303-12392-1-git-send-email-sathya.perla@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@broadcom.com>
Date: Tue, 29 Aug 2017 11:45:03 +0530

> When bnxt VF-reps are not compiled in (CONFIG_BNXT_SRIOV is off)
> bnxt_tc.c needs a dummy definition of the routine bnxt_vf_rep_get_fid().
> 
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Fixes: 2ae7408fedfe ("bnxt_en: bnxt: add TC flower filter offload support")
> Signed-off-by: Sathya Perla <sathya.perla@broadcom.com>

Applied.
