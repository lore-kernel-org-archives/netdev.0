From: Anton Aksola <aakso@iki.fi>
Subject: Re: [PATCH] iproute2: build nsid-name cache only for commands that
 need it
Date: Fri, 16 Sep 2016 06:27:35 +0000
Message-ID: <20160916062735.GA10406@toys.tundra.dog-lvm.novalocal>
References: <20160915082326.GA1635@toys.tundra.dog-lvm.novalocal>
 <2ab25704-d8aa-1532-a07a-c1765b937d66@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-78.nebula.fi ([83.145.220.78]:35722 "EHLO smtp.nebula.fi"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753228AbcIPG1d (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 16 Sep 2016 02:27:33 -0400
Content-Disposition: inline
In-Reply-To: <2ab25704-d8aa-1532-a07a-c1765b937d66@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 15, 2016 at 03:26:18PM +0200, Nicolas Dichtel wrote:
[snip]
> 'ip netns' (ip netns list) also need it.

Thanks, I missed your other commit that introduced it. Sending an updated patch.
