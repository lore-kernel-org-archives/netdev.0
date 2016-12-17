From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/x25: use designated initializers
Date: Sat, 17 Dec 2016 11:58:12 -0500 (EST)
Message-ID: <20161217.115812.1170388230079582920.davem@davemloft.net>
References: <20161217010339.GA140529@beast>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, andrew.hendry@gmail.com,
        linux-x25@vger.kernel.org, netdev@vger.kernel.org
To: keescook@chromium.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41826 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1761482AbcLQQ6O (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Dec 2016 11:58:14 -0500
In-Reply-To: <20161217010339.GA140529@beast>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kees Cook <keescook@chromium.org>
Date: Fri, 16 Dec 2016 17:03:39 -0800

> Prepare to mark sensitive kernel structures for randomization by making
> sure they're using designated initializers. These were identified during
> allyesconfig builds of x86, arm, and arm64, with most initializer fixes
> extracted from grsecurity.
> 
> Signed-off-by: Kees Cook <keescook@chromium.org>

Applied.
