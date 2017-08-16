From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 00/10] BPF: sockmap and sk redirect support
Date: Wed, 16 Aug 2017 11:28:19 -0700 (PDT)
Message-ID: <20170816.112819.1162151697604053267.davem@davemloft.net>
References: <20170816052338.15445.83732.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, ast@fb.com, tgraf@suug.ch,
        netdev@vger.kernel.org, tom@herbertland.com
To: john.fastabend@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34980 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751841AbdHPS2U (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 14:28:20 -0400
In-Reply-To: <20170816052338.15445.83732.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.fastabend@gmail.com>
Date: Tue, 15 Aug 2017 22:30:15 -0700

> This series implements a sockmap and socket redirect helper for BPF
> using a model similar to XDP netdev redirect.

Series applied, thanks John.
