From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next] r8169: Replace TX_DMA_BURST
Date: Mon, 17 Aug 2015 21:20:48 +0300
Message-ID: <55D22600.9060404@cogentembedded.com>
References: <1439833342-2948-1-git-send-email-corcodel.marian@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Corcodel Marian <corcodel.marian@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f178.google.com ([209.85.217.178]:35222 "EHLO
	mail-lb0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750916AbbHQSUw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Aug 2015 14:20:52 -0400
Received: by lbcbn3 with SMTP id bn3so87331817lbc.2
        for <netdev@vger.kernel.org>; Mon, 17 Aug 2015 11:20:50 -0700 (PDT)
In-Reply-To: <1439833342-2948-1-git-send-email-corcodel.marian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/17/2015 08:42 PM, Corcodel Marian wrote:

> Replace TX_DMA_BURST with 3 wich corespond on 128

    s/on/to/?

>   descriptors  send on Tx burst DMA .Packet size consist in unit of 128

    s/send/sent/? And please place period at the end of the statement, not at 
the beginning of a new one.

>   descriptors.  Ensure to  keep this units grouped
>
>
> Signed-off-by: Corcodel Marian <corcodel.marian@gmail.com>

[...]

MBR, Sergei
