From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 5/7] bpf: Add verifier test case for alignment.
Date: Thu, 11 May 2017 17:53:47 -0400 (EDT)
Message-ID: <20170511.175347.1784432804227034764.davem@davemloft.net>
References: <20170511.120601.246881624526451669.davem@davemloft.net>
        <20170511211945.GB20107@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, ast@fb.com, alexei.starovoitov@gmail.com,
        netdev@vger.kernel.org
To: alexander@alemayhu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55070 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756404AbdEKVxw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 11 May 2017 17:53:52 -0400
In-Reply-To: <20170511211945.GB20107@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Alemayhu <alexander@alemayhu.com>
Date: Thu, 11 May 2017 23:19:45 +0200

> Why is this commented out?

That was a debugging hack while developing this code, I'll
remove it.

Thanks.
