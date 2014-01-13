From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next] ipv4: remove the  useless argument from ip_tunnel_hash()
Date: Mon, 13 Jan 2014 17:55:15 +0400
Message-ID: <52D3F043.9090200@cogentembedded.com>
References: <52D2689A.4040800@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Duan Jiong <duanj.fnst@cn.fujitsu.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f178.google.com ([209.85.217.178]:42773 "EHLO
	mail-lb0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751434AbaAMNzR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jan 2014 08:55:17 -0500
Received: by mail-lb0-f178.google.com with SMTP id u14so1353390lbd.37
        for <netdev@vger.kernel.org>; Mon, 13 Jan 2014 05:55:15 -0800 (PST)
In-Reply-To: <52D2689A.4040800@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 12-01-2014 14:04, Duan Jiong wrote:

> Since commit c544193214 introduced function ip_tunnel_hash(), the argument

   Please also specify that commit's summary line in parens.

> itn is no longer in use, so remove it.

> Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>

WBR, Sergei
