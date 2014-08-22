From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] sctp: not send SCTP_PEER_ADDR_CHANGE notifications
 with failed probe
Date: Thu, 21 Aug 2014 21:35:23 -0700 (PDT)
Message-ID: <20140821.213523.1210166206674176289.davem@davemloft.net>
References: <1408527103-22772-1-git-send-email-Yanjun.Zhu@windriver.com>
	<1408527103-22772-2-git-send-email-Yanjun.Zhu@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, vyasevich@gmail.com, tuexen@fh-muenster.de,
	khandelwal.deepak.1987@gmail.com, Yue.Tao@windriver.com,
	alexandre.dietsch@windriver.com, Yanjun.Zhu@windriver.com
To: zyjzyj2000@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1408527103-22772-2-git-send-email-Yanjun.Zhu@windriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Zhu Yanjun <zyjzyj2000@gmail.com>
Date: Wed, 20 Aug 2014 17:31:43 +0800

> Since the transport has always been in state SCTP_UNCONFIRMED, it
> therefore wasn't active before and hasn't been used before, and it
> always has been, so it is unnecessary to bug the user with a 
> notification.
> 
> Reported-by: Deepak Khandelwal <khandelwal.deepak.1987@gmail.com>  
> Suggested-by: Vlad Yasevich <vyasevich@gmail.com> 
> Suggested-by: Michael Tuexen <tuexen@fh-muenster.de>
> Suggested-by: Daniel Borkmann <dborkman@redhat.com>
> Signed-off-by: Zhu Yanjun <Yanjun.Zhu@windriver.com>

Applied, thanks.
