From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] af_econet: Use current logging styles and neatening
Date: Sun, 03 Jul 2011 20:05:27 -0700 (PDT)
Message-ID: <20110703.200527.2004595152778358649.davem@davemloft.net>
References: <8e47a6e010a39bd35d3544311dd451abda8b7fb3.1309717580.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, philb@gnu.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <8e47a6e010a39bd35d3544311dd451abda8b7fb3.1309717580.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Sun,  3 Jul 2011 11:28:33 -0700

> Use pr_fmt() without KBUILD_MODNAME to allow AUN and econet prefixes.
> Convert printks with KERN_DEBUG to pr_debug.
> Hoist assigns from if.
> 80 column wrapping.
> Move open braces to end of line.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied, thanks.
