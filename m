From: Selvin Xavier <selvin.xavier@broadcom.com>
Subject: Re: [PATCH V2 00/22] Broadcom RoCE Driver (bnxt_re)
Date: Fri, 9 Dec 2016 23:22:00 +0530
Message-ID: <CA+sbYW1Kum=rU4CMq++=D-DjmepF_wrOA8kTH7ptQgwyP=QaRQ@mail.gmail.com>
References: <1481266096-23331-1-git-send-email-selvin.xavier@broadcom.com> <20161209.102602.181161966975624956.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Doug Ledford <dledford@redhat.com>, linux-rdma@vger.kernel.org,
        netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f172.google.com ([209.85.220.172]:34027 "EHLO
        mail-qk0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752165AbcLIRwC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Dec 2016 12:52:02 -0500
Received: by mail-qk0-f172.google.com with SMTP id q130so24924535qke.1
        for <netdev@vger.kernel.org>; Fri, 09 Dec 2016 09:52:02 -0800 (PST)
In-Reply-To: <20161209.102602.181161966975624956.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 9, 2016 at 8:56 PM, David Miller <davem@davemloft.net> wrote:
> From: Selvin Xavier <selvin.xavier@broadcom.com>
> Date: Thu,  8 Dec 2016 22:47:54 -0800
>
>> This series introduces the RoCE driver for the Broadcom
>> NetXtreme-E 10/25/40/50 gigabit RoCE HCAs.
>> This driver is dependent on the bnxt_en NIC driver and is
>> based on the bnxt_re branch in Doug's repository. bnxt_en changes
>> required for this patch series is already available in this branch.
>>
>> I am preparing a git repository with these changes as per Jason's
>> comment and will share the details later today.
>
> If this is targetted at the net-next tree, it is too late as I've
> closed the net-next tree two nights ago.
>

This patch series is targeting linux-rdma tree. netdev is copied since
this series is dependent on  bnxt_en.

Thanks
Selvin
