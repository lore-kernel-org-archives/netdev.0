From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bpf: Collapse offset checks in
 sock_filter_is_valid_access
Date: Fri, 01 Sep 2017 10:37:24 -0700 (PDT)
Message-ID: <20170901.103724.186301375875405259.davem@davemloft.net>
References: <1504279087-11379-1-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net
To: dsahern@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50076 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752275AbdIARhZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2017 13:37:25 -0400
In-Reply-To: <1504279087-11379-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsahern@gmail.com>
Date: Fri,  1 Sep 2017 08:18:07 -0700

> Make sock_filter_is_valid_access consistent with other is_valid_access
> helpers.
> 
> Requested-by: Daniel Borkmann <daniel@iogearbox.net>
> Signed-off-by: David Ahern <dsahern@gmail.com>

Applied.
