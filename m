From: Nandita Dukkipati <nanditad@google.com>
Subject: Re: [PATCH v2 net-next 2/2] tcp: add TCPWinProbe and TCPKeepAlive
 SNMP counters
Date: Thu, 7 May 2015 10:45:49 -0700
Message-ID: <CAB_+Fg6Fxo+uQXyRDk6q52NacJcHW3GrY1-JqZ=HJp+uWYpjug@mail.gmail.com>
References: <1430947585-2375-1-git-send-email-edumazet@google.com>
	<1430947585-2375-3-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f169.google.com ([209.85.216.169]:36023 "EHLO
	mail-qc0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752008AbbEGRpv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2015 13:45:51 -0400
Received: by qcbgy10 with SMTP id gy10so24974528qcb.3
        for <netdev@vger.kernel.org>; Thu, 07 May 2015 10:45:50 -0700 (PDT)
In-Reply-To: <1430947585-2375-3-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Diagnosing problems related to Window Probes has been hard because
> we lack a counter.
>
> TCPWinProbe counts the number of ACK packets a sender has to send
> at regular intervals to make sure a reverse ACK packet opening back
> a window had not been lost.
>
> TCPKeepAlive counts the number of ACK packets sent to keep TCP
> flows alive (SO_KEEPALIVE)
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>

Acked-by: Nandita Dukkipati <nanditad@google.com>
