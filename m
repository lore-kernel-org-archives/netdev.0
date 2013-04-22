From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] Net-next: ipv4: type issue, remove erroneous semicolon
Date: Mon, 22 Apr 2013 18:32:20 +0400
Message-ID: <517549F4.7030806@cogentembedded.com>
References: <51750E31.2010906@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: pshelar@nicira.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Chen Gang <gang.chen@asianux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:48177 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752031Ab3DVOde (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Apr 2013 10:33:34 -0400
Received: by mail-la0-f46.google.com with SMTP id ep20so1668702lab.19
        for <netdev@vger.kernel.org>; Mon, 22 Apr 2013 07:33:32 -0700 (PDT)
In-Reply-To: <51750E31.2010906@asianux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 22-04-2013 14:17, Chen Gang wrote:

>    need remove erroneous semicolon.

>    the related commit number: c54419321455631079c7d6e60bc732dd0c5914c5

    You also need to specify that commit's summary line in parens.

>    Find it by EXTRA_CFLAGS=-W


> Signed-off-by: Chen Gang <gang.chen@asianux.com>

WBR, Sergei
