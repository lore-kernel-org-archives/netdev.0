From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv5 2/2] memory barrier: adding smp_mb__after_lock
Date: Wed, 08 Jul 2009 11:07:36 -0700 (PDT)
Message-ID: <20090708.110736.267641562.davem@davemloft.net>
References: <20090707145710.GB7124@Krystal>
	<4A536866.1050906@gmail.com>
	<20090708174748.GB4650@jolsa.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, mathieu.desnoyers@polymtl.ca,
	mingo@elte.hu, a.p.zijlstra@chello.nl, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, fbl@redhat.com, nhorman@redhat.com,
	htejun@gmail.com, jarkao2@gmail.com, oleg@redhat.com,
	davidel@xmailserver.org
To: jolsa@redhat.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758297AbZGHSHk@vger.kernel.org>
In-Reply-To: <20090708174748.GB4650@jolsa.lab.eng.brq.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jiri Olsa <jolsa@redhat.com>
Date: Wed, 8 Jul 2009 19:47:48 +0200

> great, I saw you Signed-off the 1/2 part.. could I leave it,
> or do I need to resend as a single patch?

Could you formally resubmit things, regardless of whether
they are kept split up or combined?  That will help me
a lot.  Thanks.

I think things are settled down at this point and we can
push these patches into the tree.
