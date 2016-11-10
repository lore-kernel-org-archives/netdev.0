From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH net-next v5 0/9] net: add support for IPv6 Segment Routing
Date: Thu, 10 Nov 2016 18:27:15 +0900
Message-ID: <CAKD1Yr0uzqHxN1PTu-eXdLEyPS4Ps4oGYAF5fRVV3rN+xyjZYQ@mail.gmail.com>
References: <1478613467-27712-1-git-send-email-david.lebrun@uclouvain.be>
 <20161109.204058.1740541278564630528.davem@davemloft.net> <CAKD1Yr0fDFdDv9+S3i_rH6W6btEuvs9s-h33_N67iM4qrtDezQ@mail.gmail.com>
 <58243939.5000200@uclouvain.be> <CAKD1Yr1OGn_JS_REOL9g5gELf9s=VdGfebSrticF2=Vf-m5oKA@mail.gmail.com>
 <58243D57.2000805@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Lebrun <david.lebrun@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f47.google.com ([209.85.214.47]:36935 "EHLO
        mail-it0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932516AbcKJJ1h (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Nov 2016 04:27:37 -0500
Received: by mail-it0-f47.google.com with SMTP id u205so28577924itc.0
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2016 01:27:36 -0800 (PST)
In-Reply-To: <58243D57.2000805@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 10, 2016 at 6:26 PM, David Lebrun <david.lebrun@uclouvain.be> wrote:
> That would be easier indeed, but then this behavior should be documented
> somewhere: how the user would know that it has to enable CONFIG_LWTUNNEL ?

True.

I guess whether that question is important or not depends on how many
kernels enable CONFIG_LWTUNNEL. If pretty much all kernels already
enable it, then the point is moot.
