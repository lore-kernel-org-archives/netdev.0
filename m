From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH net repost] nfp: do not update MTU from BH in flower app
Date: Wed, 16 Aug 2017 07:35:35 +0200
Message-ID: <20170816053534.GE29880@vergenet.net>
References: <20170811.145107.1539668262080149471.davem@davemloft.net>
 <20170815061347.GA14861@vergenet.net>
 <20170815.175240.1812725528326133547.davem@davemloft.net>
 <20170815.210358.1704629747295212922.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jakub.kicinski@netronome.com, netdev@vger.kernel.org,
        oss-drivers@netronome.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f177.google.com ([209.85.128.177]:34839 "EHLO
        mail-wr0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751160AbdHPFfi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 01:35:38 -0400
Received: by mail-wr0-f177.google.com with SMTP id 49so485197wrw.2
        for <netdev@vger.kernel.org>; Tue, 15 Aug 2017 22:35:38 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170815.210358.1704629747295212922.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 15, 2017 at 09:03:58PM -0700, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Tue, 15 Aug 2017 17:52:40 -0700 (PDT)
> 
> > From: Simon Horman <simon.horman@netronome.com>
> > Date: Tue, 15 Aug 2017 08:13:48 +0200
> > 
> >> Could you pull net into net-next? I'd like to send up a follow-up
> >> for net-next to allow processing of the MTU.
> > 
> > Once Linus takes the pull request I just sent to him, I will
> > do this.
> 
> And this is now done.

Great, thanks.
