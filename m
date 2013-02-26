From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH BUGFIX] pkt_sched: fix little service anomalies and
 possible crashes of qfq+
Date: Tue, 26 Feb 2013 17:37:00 -0500 (EST)
Message-ID: <20130226.173700.882998504986475149.davem@davemloft.net>
References: <20121226.151355.2215825989495032073.davem@davemloft.net>
	<1361898166-18295-1-git-send-email-paolo.valente@unimore.it>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, shemminger@vyatta.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, fchecconi@gmail.com,
	rizzo@iet.unipi.it
To: paolo.valente@unimore.it
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1361898166-18295-1-git-send-email-paolo.valente@unimore.it>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paolo valente <paolo.valente@unimore.it>
Date: Tue, 26 Feb 2013 18:02:46 +0100

> The portions of the code interested by each fix are small and do not
> overlap with each other, so I decided to provide just one patch
> (I hope that this was the right choice).

Please split this up into 6 patches, each with an appropriately
verbose analysis and explanation of each bug being fixed, thanks.
