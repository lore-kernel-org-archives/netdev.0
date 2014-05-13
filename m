From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH v2 1/3] net: add a sysctl to reflect the fwmark on replies
Date: Wed, 14 May 2014 02:44:33 +0900
Message-ID: <CAKD1Yr07p7xujjsQU0OrtdL53i4FPX7+9BKV-pbVZH4LN6PpTA@mail.gmail.com>
References: <1399691298-2531-1-git-send-email-lorenzo@google.com> <20140513.125236.689947368922450038.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	JP Abgrall <jpa@google.com>, Julian Anastasov <ja@ssi.bg>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:35853 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752984AbaEMRoy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2014 13:44:54 -0400
Received: by mail-ig0-f170.google.com with SMTP id r10so6188197igi.5
        for <netdev@vger.kernel.org>; Tue, 13 May 2014 10:44:53 -0700 (PDT)
In-Reply-To: <20140513.125236.689947368922450038.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 14, 2014 at 1:52 AM, David Miller <davem@davemloft.net> wrote:
> These patches do not apply cleanly to net-next.
>
> Also, you did not provide a top level initial "[PATCH 0/N] " posting
> giving a high level overview of what these changes do, and why we
> should make these changes.

Ack. I just sent out a new patchset which should apply cleanly and has
a cover letter (the first submission had one, but patch v2 didn't).
