From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] net: msm_ipc: Add user-space support for MSM_IPC
 Router
Date: Thu, 09 Jun 2011 12:35:53 -0700 (PDT)
Message-ID: <20110609.123553.784125057506332397.davem@davemloft.net>
References: <1307555467-1530-1-git-send-email-kramasub@codeaurora.org>
	<20110609.001149.2112721409565728649.davem@davemloft.net>
	<4DF0FD8A.1000304@codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-msm@vger.kernel.org
To: kramasub@codeaurora.org
Return-path: <linux-arm-msm-owner@vger.kernel.org>
In-Reply-To: <4DF0FD8A.1000304@codeaurora.org>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Karthikeyan Ramasubramanian <kramasub@codeaurora.org>
Date: Thu, 09 Jun 2011 11:06:18 -0600

> Please let me know if you need any other information.

I don't agree with creating all of this non-trivial infrastructure
for what seems to be an obscure protocol stack.

You can do all of this in userspace, it seems.
