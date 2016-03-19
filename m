From: Jesse Gross <jesse@kernel.org>
Subject: Re: [PATCH net 1/3] ipip: Properly mark ipip GRO packets as encapsulated.
Date: Sat, 19 Mar 2016 09:33:40 -0700
Message-ID: <CAEh+42ga3wG_msjxVao5y-ut4abPOQCRwA_iA8fMoGPo9BvBvg@mail.gmail.com>
References: <1458239136-37814-1-git-send-email-jesse@kernel.org> <20160318.231207.637794925156978876.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Patrick Boutilier <boutilpj@ednet.ns.ca>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:55709 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754586AbcCSQd5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 19 Mar 2016 12:33:57 -0400
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id C68A2203F3
	for <netdev@vger.kernel.org>; Sat, 19 Mar 2016 16:33:56 +0000 (UTC)
Received: from mail-qg0-f45.google.com (mail-qg0-f45.google.com [209.85.192.45])
	(using TLSv1.2 with cipher AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id D2BFC203ED
	for <netdev@vger.kernel.org>; Sat, 19 Mar 2016 16:33:55 +0000 (UTC)
Received: by mail-qg0-f45.google.com with SMTP id a36so93240311qge.0
        for <netdev@vger.kernel.org>; Sat, 19 Mar 2016 09:33:55 -0700 (PDT)
In-Reply-To: <20160318.231207.637794925156978876.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 18, 2016 at 8:12 PM, David Miller <davem@davemloft.net> wrote:
>
> Jesse, can you repost this series with a patch introductory "PATCH
> 0/3" email explaining things at a high level about what this series is
> doing?
>
> Thanks.

Sure, I just sent a v2 with a cover letter.
