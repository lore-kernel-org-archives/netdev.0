From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: Re: [PATCH v2 1/5] net: w5100: move mmiowb into register access callbacks
Date: Sat, 9 Apr 2016 03:54:46 +0900
Message-ID: <CAC5umyg4feW=XeNuOPBYDU8Ph5+AzWWnx+Wk3FDS5vWZLU5Zog@mail.gmail.com>
References: <1460045792-30594-1-git-send-email-akinobu.mita@gmail.com>
	<20160407.122951.1457426147075873743.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Mike Sinkovsky <msink@permonline.ru>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f65.google.com ([209.85.213.65]:34197 "EHLO
	mail-vk0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751046AbcDHSyw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2016 14:54:52 -0400
Received: by mail-vk0-f65.google.com with SMTP id a6so6951869vkh.1
        for <netdev@vger.kernel.org>; Fri, 08 Apr 2016 11:54:52 -0700 (PDT)
In-Reply-To: <20160407.122951.1457426147075873743.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2016-04-08 1:29 GMT+09:00 David Miller <davem@davemloft.net>:
>
> Where is your "[PATCH v2 0/5] ..." header posting explaing what this series
> is doing, at a high level, how it is doing that, and why it is doing it
> that way?
>
> This is mandator for patch series submissions.

I see.  I'll surely include the explanations at the v3 submission.
