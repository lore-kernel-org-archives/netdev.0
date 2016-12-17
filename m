From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] isdn: use designated initializers
Date: Sat, 17 Dec 2016 11:58:05 -0500 (EST)
Message-ID: <20161217.115805.435042884057426150.davem@davemloft.net>
References: <20161217010142.GA140401@beast>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, isdn@linux-pingi.de,
        mugunthanvnm@ti.com, a@unstable.cc, felipe.balbi@linux.intel.com,
        fw@strlen.de, netdev@vger.kernel.org
To: keescook@chromium.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41816 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1761897AbcLQQ6I (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Dec 2016 11:58:08 -0500
In-Reply-To: <20161217010142.GA140401@beast>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kees Cook <keescook@chromium.org>
Date: Fri, 16 Dec 2016 17:01:42 -0800

> Prepare to mark sensitive kernel structures for randomization by making
> sure they're using designated initializers. These were identified during
> allyesconfig builds of x86, arm, and arm64, with most initializer fixes
> extracted from grsecurity.
> 
> Signed-off-by: Kees Cook <keescook@chromium.org>

Applied.
