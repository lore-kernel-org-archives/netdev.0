From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net] i40e: Fix limit imprecise of the number of MAC/VLAN
 that can be added for VFs
Date: Wed, 27 Sep 2017 14:33:49 +0300
Message-ID: <fd104583-6743-9f1b-cba8-988fa1b216db@cogentembedded.com>
References: <1506495497-10736-1-git-send-email-wangyunjian@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
        caihe@huawei.com
To: w00273186 <wangyunjian@huawei.com>, davem@davemloft.net,
        jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f174.google.com ([209.85.128.174]:51356 "EHLO
        mail-wr0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752090AbdI0Ldw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2017 07:33:52 -0400
Received: by mail-wr0-f174.google.com with SMTP id z39so15870611wrb.8
        for <netdev@vger.kernel.org>; Wed, 27 Sep 2017 04:33:51 -0700 (PDT)
In-Reply-To: <1506495497-10736-1-git-send-email-wangyunjian@huawei.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

On 9/27/2017 9:58 AM, w00273186 wrote:

> From: Yunjian Wang <wangyunjian@huawei.com>
> 
> Now it don't limit the number of MAC/VLAN strictly. When there is more

    Doesn't.

> elements in the virtchnl MAC/VLAN list, it can still add successfully.
> 
> Signed-off-by: Yunjian Wang <wangyunjian@huawei.com>

[...]

MBR, Sergei
