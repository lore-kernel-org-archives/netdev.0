From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/11] sctp: remove typedefs from structures
 part 1
Date: Sat, 01 Jul 2017 09:09:00 -0700 (PDT)
Message-ID: <20170701.090900.1231795762851084102.davem@davemloft.net>
References: <cover.1498794481.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        marcelo.leitner@gmail.com, nhorman@tuxdriver.com
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59346 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751851AbdGAQJE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 1 Jul 2017 12:09:04 -0400
In-Reply-To: <cover.1498794481.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Fri, 30 Jun 2017 11:52:11 +0800

> As we know, typedef is suggested not to use in kernel, even checkpatch.pl
> also gives warnings about it. Now sctp is using it for many structures.
> 
> All this kind of typedef's using should be removed. As the 1st part, this
> patchset is to remove it for 11 basic structures in linux/sctp.h. It is
> also to fix some indents.
> 
> No any code's logic is changed in these patches, only cleaning up.

Series applied, thanks.
