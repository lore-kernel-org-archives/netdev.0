From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sctp: remove useless err from sctp_association_init
Date: Wed, 22 Mar 2017 10:58:08 -0700 (PDT)
Message-ID: <20170322.105808.1596473942928669549.davem@davemloft.net>
References: <82209fcc4742baa1c4855af7e54b88177e9d0537.1490004028.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        marcelo.leitner@gmail.com, nhorman@tuxdriver.com
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42354 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934301AbdCVR6T (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Mar 2017 13:58:19 -0400
In-Reply-To: <82209fcc4742baa1c4855af7e54b88177e9d0537.1490004028.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Mon, 20 Mar 2017 18:00:28 +0800

> This patch is to remove the unnecessary temporary variable 'err' from
> sctp_association_init.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Applied.
