From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] qlge: remove unecessary if statement
Date: Mon, 06 Jun 2011 22:53:21 -0700 (PDT)
Message-ID: <20110606.225321.625955055583754790.davem@davemloft.net>
References: <1307321053-21695-1-git-send-email-Gregory.Dietsche@cuw.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ron.mercer@qlogic.com, linux-driver@qlogic.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Gregory.Dietsche@cuw.edu
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1307321053-21695-1-git-send-email-Gregory.Dietsche@cuw.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Greg Dietsche <Gregory.Dietsche@cuw.edu>
Date: Sun,  5 Jun 2011 19:44:13 -0500

> the code always returns 'status' regardless, so if(status) check is unecessary.
> 
> Signed-off-by: Greg Dietsche <Gregory.Dietsche@cuw.edu>

Applied, thanks.
