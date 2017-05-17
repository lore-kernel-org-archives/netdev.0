From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/3] bpf: Use 1<<16 as ceiling for immediate
 alignment in verifier.
Date: Wed, 17 May 2017 13:25:11 -0400 (EDT)
Message-ID: <20170517.132511.584823594052124308.davem@davemloft.net>
References: <50288778-10f6-7201-c979-bfe4635831fc@solarflare.com>
        <20170517.121313.1437427582437926345.davem@davemloft.net>
        <fae2fc09-d26e-213a-cd9d-1699db691515@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, daniel@iogearbox.net, alexei.starovoitov@gmail.com,
        netdev@vger.kernel.org
To: ecree@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34916 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751398AbdEQRZO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 17 May 2017 13:25:14 -0400
In-Reply-To: <fae2fc09-d26e-213a-cd9d-1699db691515@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Edward Cree <ecree@solarflare.com>
Date: Wed, 17 May 2017 18:00:03 +0100

> Did you see the algorithms I posted with two masks?

I'll take a look.
