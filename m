From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Subject: Re: [PATCH v2 net-next 0/2] tcp: tcp_info extensions
Date: Tue, 12 May 2015 10:08:55 -0300
Message-ID: <20150512130855.GA29412@localhost.localdomain>
References: <1430260098-14127-1-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Yuchung Cheng <ycheng@google.com>,
	Matt Mathis <mattmathis@google.com>,
	Eric Salo <salo@google.com>, Martin Lau <kafai@fb.com>,
	Chris Rapier <rapier@psc.edu>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42695 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932339AbbELNJA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 May 2015 09:09:00 -0400
Content-Disposition: inline
In-Reply-To: <1430260098-14127-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 28, 2015 at 03:28:16PM -0700, Eric Dumazet wrote:
> As discussed during Chris Rapier presentation in Ottawa / netdev0.1,
> we add to tcp_info the first two fields are highly wanted.
> 
> Each field is added into a single patch for easy code review.
> 
> (Corresponding iproute2/ss patches will be sent)
> 
> Next fields will follow once consensus is reached.

Is tcpEStatsPerfSegsOut amongst them? I have a need for this one and can
submit a patch if you're not tracking it already.

  Marcelo
