From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next] core: Simplify logic in dev_load().
Date: Tue, 02 Sep 2014 21:49:48 +0400
Message-ID: <5406033C.40507@cogentembedded.com>
References: <063D6719AE5E284EB5DD2968C1650D6D174856D6@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: David Laight <David.Laight@ACULAB.COM>,
	Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f45.google.com ([209.85.215.45]:50538 "EHLO
	mail-la0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753710AbaIBRtw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2014 13:49:52 -0400
Received: by mail-la0-f45.google.com with SMTP id pn19so8267931lab.4
        for <netdev@vger.kernel.org>; Tue, 02 Sep 2014 10:49:50 -0700 (PDT)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D174856D6@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 09/02/2014 05:51 PM, David Laight wrote:

> The code in dev_load() is convoluted.
> Return early and remove the 'no_module' variable.

    You forgot to sign off on the patch, so it can't be applied.

WBR, Sergei
