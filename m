From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 3/5] sock_diag: allow to dump bpf filters
Date: Tue, 23 Apr 2013 08:31:04 -0700
Message-ID: <1366731064.8964.1.camel@edumazet-glaptop>
References: <1366727277-19522-1-git-send-email-nicolas.dichtel@6wind.com>
	 <1366727277-19522-4-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:35188 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756822Ab3DWPbH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Apr 2013 11:31:07 -0400
Received: by mail-pd0-f181.google.com with SMTP id y10so502634pdj.40
        for <netdev@vger.kernel.org>; Tue, 23 Apr 2013 08:31:06 -0700 (PDT)
In-Reply-To: <1366727277-19522-4-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-04-23 at 16:27 +0200, Nicolas Dichtel wrote:
> This patch allows to dump BPF filters attached to a socket. For now, only packet
> sockets use this feature.

A detailed changelog on security implication of such change would be
welcomed.

Thanks
