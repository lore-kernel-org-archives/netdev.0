From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] vxlan: remove the useless header file protocol.h
Date: Fri, 26 Aug 2016 21:49:05 -0700 (PDT)
Message-ID: <20160826.214905.1196336305689954074.davem@davemloft.net>
References: <1471959044-29985-1-git-send-email-zyjzyj2000@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pabeni@redhat.com, daniel@iogearbox.net,
        pshelar@nicira.com, aduyck@mirantis.com,
        hannes@stressinduktion.org, jbenc@redhat.com
To: zyjzyj2000@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34245 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750798AbcH0EtH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 27 Aug 2016 00:49:07 -0400
In-Reply-To: <1471959044-29985-1-git-send-email-zyjzyj2000@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: zyjzyj2000@gmail.com
Date: Tue, 23 Aug 2016 21:30:44 +0800

> From: Zhu Yanjun <zyjzyj2000@gmail.com>
> 
> This header file is not used in vxlan.c file.
> 
> Signed-off-by: Zhu Yanjun <zyjzyj2000@gmail.com>

Applied to net-next, thanks.
