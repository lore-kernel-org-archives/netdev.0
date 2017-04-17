From: David Miller <davem@redhat.com>
Subject: Re: [PATCH] net: cx89x0: move attribute declaration before struct
 keyword
Date: Mon, 17 Apr 2017 16:44:27 -0400 (EDT)
Message-ID: <20170417.164427.2187992626189209767.davem@redhat.com>
References: <20170417062032.22764-1-stefan@agner.ch>
        <20170417.160942.2196583103295700079.davem@redhat.com>
        <6fbaa209a827778ff56a7ac3b36e5e17@agner.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shc_work@mail.ru, jarod@redhat.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: stefan@agner.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45828 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755023AbdDQUoc (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 17 Apr 2017 16:44:32 -0400
In-Reply-To: <6fbaa209a827778ff56a7ac3b36e5e17@agner.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Agner <stefan@agner.ch>
Date: Mon, 17 Apr 2017 13:31:28 -0700

> Given that, can you reconsider?

Please put the attribute after the compete type.

Thanks.
