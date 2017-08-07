From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH v3 net-next 0/7] net: l3mdev: Support for sockets bound to
 enslaved device
Date: Mon, 7 Aug 2017 12:40:51 -0600
Message-ID: <0f8edad8-1ea9-c6e6-4410-6471ee4c212e@gmail.com>
References: <1502120662-1430-1-git-send-email-dsahern@gmail.com>
 <20170807.113942.927598740175023982.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f47.google.com ([74.125.83.47]:36530 "EHLO
        mail-pg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751426AbdHGSkx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 14:40:53 -0400
Received: by mail-pg0-f47.google.com with SMTP id v77so4800173pgb.3
        for <netdev@vger.kernel.org>; Mon, 07 Aug 2017 11:40:53 -0700 (PDT)
In-Reply-To: <20170807.113942.927598740175023982.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/7/17 12:39 PM, David Miller wrote:
> Series applied, let's see if it builds this time :-)

I did an allyesconfig build before sending just to make sure, so our
mileage better not vary.
