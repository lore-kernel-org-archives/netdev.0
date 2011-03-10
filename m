From: David Miller <davem@davemloft.net>
Subject: Re: [patch] ariadne: remove redundant NULL check
Date: Thu, 10 Mar 2011 14:39:42 -0800 (PST)
Message-ID: <20110310.143942.183042624.davem@davemloft.net>
References: <20110310223636.GA11399@asset.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: j223yang@asset.uwaterloo.ca
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110310223636.GA11399@asset.uwaterloo.ca>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: j223yang@asset.uwaterloo.ca
Date: Thu, 10 Mar 2011 17:36:37 -0500

> Simply remove redundant 'dev' NULL check.
> Source code uses spaces instead of TAB, except 'printk' and 'return' lines.
> 
> 
> Signed-off-by: Jinqiu Yang <crindy646@gmail.com>

Patch is still corrupted by your email client, the same way as before.
And when you fix it, you don't need to mention this in the commit
message.

Please, take the time to do some testing by sending the patch to
yourself, and then try to apply the patch in the email you receive.
