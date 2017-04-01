From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/3] BPF fixes on map_value_adj reg types
Date: Sat, 01 Apr 2017 12:37:01 -0700 (PDT)
Message-ID: <20170401.123701.2089842711923355892.davem@davemloft.net>
References: <cover.1490918592.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ast@fb.com, jbacik@fb.com, kafai@fb.com
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57042 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751880AbdDAThF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 1 Apr 2017 15:37:05 -0400
In-Reply-To: <cover.1490918592.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Fri, 31 Mar 2017 02:24:01 +0200

> This set adds two fixes for map_value_adj register type in the
> verifier and user space tests along with them for the BPF self
> test suite. For details, please see individual patches.

Series applied and queued up for -stable, thanks Daniel.
