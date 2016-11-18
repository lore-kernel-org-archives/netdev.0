From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netns: make struct pernet_operations::id unsigned int
Date: Fri, 18 Nov 2016 11:08:34 -0500 (EST)
Message-ID: <20161118.110834.2301462568173120823.davem@davemloft.net>
References: <20161117015821.GA1200@avx2>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59148 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751527AbcKRQIg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2016 11:08:36 -0500
In-Reply-To: <20161117015821.GA1200@avx2>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Thu, 17 Nov 2016 04:58:21 +0300

> Make struct pernet_operations::id unsigned.
 ...
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Applied, thank you.
