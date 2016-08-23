From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: [Intel-wired-lan] [PATCH -next] ixgbe: Fix non static symbol
        warnings
Date: Tue, 23 Aug 2016 17:18:01 +0000
Message-ID: <87618083B2453E4A8714035B62D67992506CA9C8@FMSMSX105.amr.corp.intel.com>
References: <1471964842-335-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
        Wei Yongjun <weiyongjun1@huawei.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Wei Yongjun <weiyj.lk@gmail.com>,
        "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:14332 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753382AbcHWRSI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 23 Aug 2016 13:18:08 -0400
In-Reply-To: <1471964842-335-1-git-send-email-weiyj.lk@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Intel-wired-lan [mailto:intel-wired-lan-bounces@lists.osuosl.org] On
>Behalf Of Wei Yongjun
>Sent: Tuesday, August 23, 2016 8:07 AM
>To: Kirsher, Jeffrey T <jeffrey.t.kirsher@intel.com>
>Cc: intel-wired-lan@lists.osuosl.org; Wei Yongjun <weiyongjun1@huawei.com>;
>netdev@vger.kernel.org
>Subject: [Intel-wired-lan] [PATCH -next] ixgbe: Fix non static symbol
>warnings
>
>From: Wei Yongjun <weiyongjun1@huawei.com>
>
>Fixes the following sparse warnings:
>
>drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c:2128:5: warning:
> symbol 'ixgbe_led_on_t_x550em' was not declared. Should it be static?
>drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c:2150:5: warning:
> symbol 'ixgbe_led_off_t_x550em' was not declared. Should it be static?
>
>Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>

Already resolved:
http://patchwork.ozlabs.org/patch/661647/

Thanks,
Emil
