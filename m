From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCH net v3] ipv4: allow local fragmentation in
 ip_finish_output_gso()
Date: Thu, 3 Nov 2016 22:40:52 +0200
Message-ID: <20161103224052.5e066584@halley>
References: <1478118977-19608-1-git-send-email-lrichard@redhat.com>
        <20161103.161244.1518109748163260273.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: lrichard@redhat.com, netdev@vger.kernel.org, fw@strlen.de,
        jtluka@redhat.com, hannes@stressinduktion.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:35897 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756553AbcKCUk7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 16:40:59 -0400
Received: by mail-wm0-f68.google.com with SMTP id c17so782863wmc.3
        for <netdev@vger.kernel.org>; Thu, 03 Nov 2016 13:40:59 -0700 (PDT)
In-Reply-To: <20161103.161244.1518109748163260273.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 03 Nov 2016 16:12:44 -0400 (EDT) David Miller <davem@davemloft.net> wrote:
> Applied and queued up for -stable.

Dave, my response lagged your "Applied" by few minutes ;)

This seems to deserve some more thought to make sure nothing got broken,
as expressed last in https://patchwork.ozlabs.org/patch/690594/

Best,
Shmulik
