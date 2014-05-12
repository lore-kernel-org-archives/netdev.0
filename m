From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCH] af_key: return error when meet errors on
 sendmsg() syscall
Date: Mon, 12 May 2014 10:41:23 -0400 (EDT)
Message-ID: <20140512.104123.348250032130742338.davem@davemloft.net>
References: <1399614455-10551-1-git-send-email-xufeng.zhang@windriver.com>
	<20140512.011141.74073195599318391.davem@davemloft.net>
	<53706495.1050303@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: xufeng.zhang@windriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <53706495.1050303@windriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Xufeng Zhang <xufeng.zhang@windriver.com>
Date: Mon, 12 May 2014 14:05:09 +0800

> I know what you mean, but isn't the kernel API aimed to facilitate the
> implementation of user space?

Yes, but as I stated the communication is message oriented and this
includes the errors.
