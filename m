From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v3 1/3] igb: Add igb_disable_sriov in error handling
Date: Tue, 23 Dec 2014 14:23:03 +0300
Message-ID: <54995097.8090105@cogentembedded.com>
References: <1419319024-30455-1-git-send-email-baijiaju1990@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux.nics@intel.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
To: Jia-Ju Bai <baijiaju1990@163.com>, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com, bruce.w.allan@intel.com,
	jesse.brandeburg@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f182.google.com ([209.85.217.182]:34401 "EHLO
	mail-lb0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755096AbaLWLXH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Dec 2014 06:23:07 -0500
Received: by mail-lb0-f182.google.com with SMTP id f15so5737331lbj.27
        for <netdev@vger.kernel.org>; Tue, 23 Dec 2014 03:23:06 -0800 (PST)
In-Reply-To: <1419319024-30455-1-git-send-email-baijiaju1990@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 12/23/2014 10:17 AM, Jia-Ju Bai wrote:

> For linux-3.18.0

    For the future: such words should be placed under --- tear line...

> The driver lacks igb_disable_sriov in error handling,
> which should match igb_enable_sriov in igb_probe.
> This patch fixes this problem, and it has been tested in runtime.

> Signed-off-by: Jia-Ju Bai <baijiaju1990@163.com>
> ---

    .... here.

>   drivers/net/ethernet/intel/igb/igb_main.c |    4 ++++
>   1 file changed, 4 insertions(+)

WBR, Sergei
