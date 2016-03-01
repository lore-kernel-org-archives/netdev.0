From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [net-next 1/4] vxlan: use reset to set header pointers
Date: Tue, 1 Mar 2016 17:39:14 +0300
Message-ID: <56D5A992.1060604@cogentembedded.com>
References: <1456824458-19499-1-git-send-email-zhangshengju@cmss.chinamobile.com>
 <1456824458-19499-2-git-send-email-zhangshengju@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Zhang Shengju <zhangshengju@cmss.chinamobile.com>,
	davem@davemloft.net, kvalo@codeaurora.org,
	johannes@sipsolutions.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f175.google.com ([209.85.217.175]:35021 "EHLO
	mail-lb0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753469AbcCAOjR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 09:39:17 -0500
Received: by mail-lb0-f175.google.com with SMTP id bc4so100199527lbc.2
        for <netdev@vger.kernel.org>; Tue, 01 Mar 2016 06:39:16 -0800 (PST)
In-Reply-To: <1456824458-19499-2-git-send-email-zhangshengju@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 3/1/2016 12:27 PM, Zhang Shengju wrote:

> Since offset is zeor, it's not necessary to use set function. Reset

    Zero in this and the other patches.

> function is straightforward, and will remove the unnecessary add operation
> in set function.
>
> Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
[...]

MBR, Sergei
