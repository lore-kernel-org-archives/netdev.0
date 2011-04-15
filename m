From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] net-bonding: Fix minor sparse complaints
Date: Thu, 14 Apr 2011 22:03:55 -0700 (PDT)
Message-ID: <20110414.220355.189708723.davem@davemloft.net>
References: <1302744151-12452-1-git-send-email-decot@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, andy@greyhouse.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: decot@google.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1302744151-12452-1-git-send-email-decot@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Decotigny <decot@google.com>
Date: Wed, 13 Apr 2011 18:22:29 -0700

> This gets rid of minor sparse complaints:
> drivers/net/bonding/bond_main.c:4361:4: warning: do-while statement is not a compound statement
> drivers/net/bonding/bond_main.c:243:12: warning: symbol 'bond_mode_name' was not declared. Should it be static?
> 
> Signed-off-by: David Decotigny <decot@google.com>

Applied.
