From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH net-next 00/11] sctp: remove typedefs from structures
 part 1
Date: Fri, 30 Jun 2017 13:57:49 -0300
Message-ID: <20170630165749.GO18138@localhost.localdomain>
References: <cover.1498794481.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61717 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751792AbdF3Q5x (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 30 Jun 2017 12:57:53 -0400
Content-Disposition: inline
In-Reply-To: <cover.1498794481.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 30, 2017 at 11:52:11AM +0800, Xin Long wrote:
> As we know, typedef is suggested not to use in kernel, even checkpatch.pl
> also gives warnings about it. Now sctp is using it for many structures.
> 
> All this kind of typedef's using should be removed. As the 1st part, this
> patchset is to remove it for 11 basic structures in linux/sctp.h. It is
> also to fix some indents.
> 
> No any code's logic is changed in these patches, only cleaning up.

Acked-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Thanks.

  Marcelo
