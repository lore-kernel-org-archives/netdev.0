From: Vincent Bernat <vincent@bernat.im>
Subject: [PATCH net-next] tcp: more documentation for tcp_tw_reuse and tcp_tw_recycle
Date: Sun,  4 May 2014 11:41:38 +0200
Message-ID: <1399196499-8449-1-git-send-email-vincent@bernat.im>
To: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>, linux-doc@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
Return-path: <linux-doc-owner@vger.kernel.org>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

I think this is not the first tentative to try to complete the
documentation of tcp_tw_reuse and tcp_tw_recycle. Last one was 4 years
ago I think. Here is another one which tries to stay short, warns
about the dangers of recycling and which kind of connections are
affected. The general warning is kept.
