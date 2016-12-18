From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] isdn: Constify some function parameters
Date: Sat, 17 Dec 2016 21:46:45 -0500 (EST)
Message-ID: <20161217.214645.1706624740221041771.davem@davemloft.net>
References: <20161216214047.GA90306@beast>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, linux-kernel@vger.kernel.org,
        re.emese@gmail.com, netdev@vger.kernel.org
To: keescook@chromium.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161216214047.GA90306@beast>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kees Cook <keescook@chromium.org>
Date: Fri, 16 Dec 2016 13:40:47 -0800

> From: Emese Revfy <re.emese@gmail.com>
> 
> The coming initify gcc plugin expects const pointer types, and caught
> some __printf arguments that weren't const yet. This fixes those.
> 
> Signed-off-by: Emese Revfy <re.emese@gmail.com>
> [kees: expanded commit message]
> Signed-off-by: Kees Cook <keescook@chromium.org>

Applied.
