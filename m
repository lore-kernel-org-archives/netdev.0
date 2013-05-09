From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH net 1/2] net/mlx4_core: Add missing report on VST and
 spoof-checking dev caps
Date: Thu, 9 May 2013 11:14:28 +0300
Message-ID: <518B5AE4.7090406@mellanox.com>
References: <1368016228-19783-1-git-send-email-ogerlitz@mellanox.com> <1368016228-19783-2-git-send-email-ogerlitz@mellanox.com> <518A7626.5060409@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<amirv@mellanox.com>, <ronye@mellanox.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog120.obsmtp.com ([207.126.144.149]:43090 "EHLO
	eu1sys200aog120.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751249Ab3EIIOe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 May 2013 04:14:34 -0400
In-Reply-To: <518A7626.5060409@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/05/2013 18:58, Sergei Shtylyov wrote:
>> +        [7] = "FSM (MAC unti-spoofing) support"
>
>     Perhaps "anti-"?

sure, fixing and will send V1, thanks spotting this over
