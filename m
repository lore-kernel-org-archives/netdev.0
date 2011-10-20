From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next]alx: Atheros AR8131/AR8151/AR8152/AR8161
 Ethernet driver
Date: Thu, 20 Oct 2011 05:25:06 -0400 (EDT)
Message-ID: <20111020.052506.373437241768777548.davem@davemloft.net>
References: <1319093184-19696-1-git-send-email-cloud.ren@Atheros.com>
	<20111020.044541.970282389722164761.davem@davemloft.net>
	<6349D7A510622448B1BA0967850A8438011CC21D@nasanexd02d.na.qualcomm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rodrigue@qca.qualcomm.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: cjren@qca.qualcomm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <6349D7A510622448B1BA0967850A8438011CC21D@nasanexd02d.na.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Ren, Cloud" <cjren@qca.qualcomm.com>
Date: Thu, 20 Oct 2011 09:23:07 +0000

> As you saw, should I do the two following steps?
> 1. I firstly try to submit code to linux-staging.git. 
> 2. After the driver have been accepted by  linux-staging.git, I submit to net-next.git again.

You submit and get it into staging so that it can sit there for some
time and get reviewed and improved by others.

One doesn't submit directly to net-next right after it gets into
staging, staging is a place where your driver lives while it still
smelly funky and needs more work.
