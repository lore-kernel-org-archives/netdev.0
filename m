From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2] audit: log 32-bit socketcalls
Date: Mon, 16 Jan 2017 16:55:14 -0500 (EST)
Message-ID: <20170116.165514.1326330119443005527.davem@davemloft.net>
References: <dd937da01da72da9277e44ed79abd1f4618c14c5.1484297765.git.rgb@redhat.com>
        <20170116.132745.1831536278596554491.davem@davemloft.net>
        <CAHC9VhQwVOQ+-iZ1iC-efVvCUadMCdRJS60wqgUQWgExL51yEw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rgb@redhat.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-audit@redhat.com
To: paul@paul-moore.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49512 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750996AbdAPVzQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Jan 2017 16:55:16 -0500
In-Reply-To: <CAHC9VhQwVOQ+-iZ1iC-efVvCUadMCdRJS60wqgUQWgExL51yEw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Moore <paul@paul-moore.com>
Date: Mon, 16 Jan 2017 15:38:33 -0500

> David, assuming Richard makes your requested changes, any objection if
> I merge this via the audit tree instead of the netdev tree?  It's a
> bit easier for us from a testing perspective this way ...

No objection.
