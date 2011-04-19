From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] acenic: Fix using the specified speed when configuring
 NIC
Date: Mon, 18 Apr 2011 22:46:42 -0700 (PDT)
Message-ID: <20110418.224642.71106517.davem@davemloft.net>
References: <1303001827-4283-1-git-send-email-decot@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jes@trained-monkey.org, linux-acenic@sunsite.dk,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: decot@google.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1303001827-4283-1-git-send-email-decot@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Decotigny <decot@google.com>
Date: Sat, 16 Apr 2011 17:57:07 -0700

> This patch needs review, as I did not test it: I only think something
> is weird by looking at the code, but experts must confirm.
> 
> This tells the NIC to take the speed specified by ethtool into account
> when configuring the NIC, instead of keeping the previous speed.
> 
> Signed-off-by: David Decotigny <decot@google.com>

Looks correct, but seems to be dependent upon some other patches which
have feedback pending which you need to address.

Please resubmit that when the other series ends up being applied after
you've fixed it up.
