From: David Miller <davem@davemloft.net>
Subject: Re: LTP recv/recvmsg tests failing on 3.17
Date: Tue, 23 Sep 2014 11:59:41 -0400 (EDT)
Message-ID: <20140923.115941.993388311316600195.davem@davemloft.net>
References: <20140923091108.2788de76@as>
	<CA+FuTScNSGYxWtB-D_iL_7TQO=z4r5_29-W8d=VRwh1M6Ym_UQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cebbert.lkml@gmail.com, netdev@vger.kernel.org
To: willemb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35122 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751572AbaIWP7n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2014 11:59:43 -0400
In-Reply-To: <CA+FuTScNSGYxWtB-D_iL_7TQO=z4r5_29-W8d=VRwh1M6Ym_UQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>
Date: Tue, 23 Sep 2014 10:57:41 -0400

> I think applications simply cannot assume a consistent
> return value when passing unsupported combinations
> of flags. This is undefined behavior.

Agreed.
