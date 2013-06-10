From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next] ipv4: remove is_data also from ip_options documentation.
Date: Mon, 10 Jun 2013 16:29:20 +0400
Message-ID: <51B5C6A0.7040408@cogentembedded.com>
References: <1370874429-4458-1-git-send-email-ramirose@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Rami Rosen <ramirose@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f54.google.com ([209.85.215.54]:52849 "EHLO
	mail-la0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750769Ab3FJM3Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jun 2013 08:29:25 -0400
Received: by mail-la0-f54.google.com with SMTP id ec20so5679388lab.13
        for <netdev@vger.kernel.org>; Mon, 10 Jun 2013 05:29:23 -0700 (PDT)
In-Reply-To: <1370874429-4458-1-git-send-email-ramirose@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 10-06-2013 18:27, Rami Rosen wrote:

> commit ef722495c8867aacc1db0675a6737e5cf1e72e07

    Please also speify that commit's summary line in parens.

> removed the unused is_data
> member from ip_options struct.

> This patch removes is_data also from the documentation of the ip_options struct.

> Signed-off-by: Rami Rosen <ramirose@gmail.com>

WBR, Sergei
