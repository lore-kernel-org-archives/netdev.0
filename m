From: Sedat Dilek <sedat.dilek@googlemail.com>
Subject: Re: [PATCH] ipv6: Prevent access to uninitialized fib_table_hash via /proc/net/ipv6_route
Date: Sat, 16 Jun 2012 11:46:06 +0200
Message-ID: <CA+icZUW7D-L4K8981oRNKgezn1Dw0ESqW_RMsYjmBx2jh4xOdw@mail.gmail.com>
Reply-To: sedat.dilek@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f174.google.com ([209.85.216.174]:53094 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753951Ab2FPJqH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Jun 2012 05:46:07 -0400
Received: by qcro28 with SMTP id o28so2111147qcr.19
        for <netdev@vger.kernel.org>; Sat, 16 Jun 2012 02:46:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I pulled net.git#master on top of latest Linus upstream GIT.

The revert [1] fixes machine's kernel-panic.
Thanks.

Regards,
- Sedat -


[1] http://git.kernel.org/?p=linux/kernel/git/davem/net.git;a=commitdiff;h=e8803b6c387129059e04d9e14d49efda250a7361
