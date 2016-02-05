From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 5/7] soreuseport: Prep for fast reuseport TCP
 socket selection
Date: Thu, 04 Feb 2016 21:37:16 -0800
Message-ID: <1454650636.7627.302.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1454600118-30152-1-git-send-email-kraigatgoog@gmail.com>
	 <1454600118-30152-6-git-send-email-kraigatgoog@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Craig Gallek <kraigatgoog@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:34541 "EHLO
	mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751254AbcBEFhR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Feb 2016 00:37:17 -0500
Received: by mail-pf0-f178.google.com with SMTP id o185so62726716pfb.1
        for <netdev@vger.kernel.org>; Thu, 04 Feb 2016 21:37:17 -0800 (PST)
In-Reply-To: <1454600118-30152-6-git-send-email-kraigatgoog@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-02-04 at 10:35 -0500, Craig Gallek wrote:
> From: Craig Gallek <kraig@google.com>
> 
> Both of the lines in this patch probably should have been included
> in the initial implementation of this code for generic socket
> support, but weren't technically necessary since only UDP sockets
> were supported.

Acked-by: Eric Dumazet <edumazet@google.com>
