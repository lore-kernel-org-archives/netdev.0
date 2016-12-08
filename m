From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V3 0/7] liquidio VF data path
Date: Thu, 08 Dec 2016 13:25:21 -0500 (EST)
Message-ID: <20161208.132521.815944253728602468.davem@davemloft.net>
References: <1481129677-10586-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: rvatsavayi@caviumnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36084 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751388AbcLHSZ0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 13:25:26 -0500
In-Reply-To: <1481129677-10586-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Date: Wed, 7 Dec 2016 08:54:30 -0800

> Following is V3 patch series that adds support for VF
> data path related features. It also has following changes
> related to previous comments:
> 1) Remove unnecessary "void *" casting.
> 2) Remove inline for functions and let gcc decide.
> 
> Please apply patches in following order as some of them
> depend on earlier patches.

Series applied.
