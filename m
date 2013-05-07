From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v3 7/9] net: sh-eth: Add irq configureation flags in sh_eth_cpu_data
Date: Tue, 07 May 2013 19:02:39 +0400
Message-ID: <5189178F.10402@cogentembedded.com>
References: <1367903875-32606-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com> <1367903875-32606-7-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshihiro.shimoda.uh@renesas.com
To: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f53.google.com ([209.85.215.53]:42351 "EHLO
	mail-la0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752300Ab3EGPCn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 May 2013 11:02:43 -0400
Received: by mail-la0-f53.google.com with SMTP id eo20so677706lab.40
        for <netdev@vger.kernel.org>; Tue, 07 May 2013 08:02:41 -0700 (PDT)
In-Reply-To: <1367903875-32606-7-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07-05-2013 9:17, Nobuhiro Iwamatsu wrote:

> sh-eth is supporting some SH and shmobile CPU. CPU with two or more network
> devices is in these, these specify IRQF_SHARED as IRQ configureation flags.
> This changes to set IRQ configureation flags using in sh_eth_cpu_data.

    Only "configuration" (and the same typo in the subject).

> Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>

WBR, Sergei
