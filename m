From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] net: msm_ipc: Add user-space support for MSM_IPC
 Router
Date: Thu, 09 Jun 2011 00:11:49 -0700 (PDT)
Message-ID: <20110609.001149.2112721409565728649.davem@davemloft.net>
References: <1307555467-1530-1-git-send-email-kramasub@codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-msm@vger.kernel.org
To: kramasub@codeaurora.org
Return-path: <linux-arm-msm-owner@vger.kernel.org>
In-Reply-To: <1307555467-1530-1-git-send-email-kramasub@codeaurora.org>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


There is no reason to create a whole new socket address family, use
genetlink instead.
