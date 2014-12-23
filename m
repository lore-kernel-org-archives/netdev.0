From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net] neigh: remove next ptr from struct neigh_table
Date: Tue, 23 Dec 2014 11:57:07 -0800
Message-ID: <CAM_iQpX4s3AicuWpEQvBtM5mUHoTHquYGHFYZP8vBpP=SP3Z2w@mail.gmail.com>
References: <1419353437-4213-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:48060 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755038AbaLWT5I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Dec 2014 14:57:08 -0500
Received: by mail-pa0-f49.google.com with SMTP id eu11so8497749pac.22
        for <netdev@vger.kernel.org>; Tue, 23 Dec 2014 11:57:07 -0800 (PST)
In-Reply-To: <1419353437-4213-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 23, 2014 at 8:50 AM, Nicolas Dichtel
<nicolas.dichtel@6wind.com> wrote:
> After commit
> d7480fd3b173 ("neigh: remove dynamic neigh table registration support"),
> this field is not used anymore.
>
> CC: Cong Wang <xiyou.wangcong@gmail.com>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Acked-by: Cong Wang <xiyou.wangcong@gmail.com>

Thanks for fixing this leftover!
