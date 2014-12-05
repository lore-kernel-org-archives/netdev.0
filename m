From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH][net-next] net: avoid to call skb_queue_len again
Date: Fri, 05 Dec 2014 17:06:42 +0300
Message-ID: <5481BBF2.40806@cogentembedded.com>
References: <1417772948-17909-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: roy.qing.li@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f171.google.com ([209.85.217.171]:48271 "EHLO
	mail-lb0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751061AbaLEOGp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2014 09:06:45 -0500
Received: by mail-lb0-f171.google.com with SMTP id n15so599410lbi.16
        for <netdev@vger.kernel.org>; Fri, 05 Dec 2014 06:06:43 -0800 (PST)
In-Reply-To: <1417772948-17909-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 12/5/2014 12:49 PM, roy.qing.li@gmail.com wrote:

> From: Li RongQing <roy.qing.li@gmail.com>

> the queue length of sd->input_pkt_queue has been putted into qlen,

    s/putted/put/, it's irregular verb.

> and impossible to change, since hold the lock

    I can't parse that. Who holds the lock?

> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

WBR, Sergei
