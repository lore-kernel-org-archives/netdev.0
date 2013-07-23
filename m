From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: r8169: remove "PHY reset until link up" log spam
Date: Tue, 23 Jul 2013 16:22:57 +0400
Message-ID: <51EE75A1.3070804@cogentembedded.com>
References: <4961229.bXDGvH0dpz@al>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	nic_swsd@realtek.com
To: Peter Wu <lekensteyn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f172.google.com ([209.85.217.172]:44522 "EHLO
	mail-lb0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756297Ab3GWMXB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jul 2013 08:23:01 -0400
Received: by mail-lb0-f172.google.com with SMTP id a16so649232lbj.31
        for <netdev@vger.kernel.org>; Tue, 23 Jul 2013 05:22:59 -0700 (PDT)
In-Reply-To: <4961229.bXDGvH0dpz@al>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 23-07-2013 13:55, Peter Wu wrote:

> This message was added in commit a7154cb8 (June 2004) and is printed

    Please also specify that commit's summary line in parens.

> every ten seconds when no cable is connected.

> Signed-off-by: Peter Wu <lekensteyn@gmail.com>

WBR, Sergei
