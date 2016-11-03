From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH iproute2] tc: flower: Fix usage message
Date: Thu, 3 Nov 2016 13:11:33 +0100
Message-ID: <20161103121132.GA16169@penelope.isobedori.kobe.vergenet.net>
References: <1478099398-21639-1-git-send-email-paulb@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>
To: Paul Blakey <paulb@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:36926 "EHLO
        mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751136AbcKCMLg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 08:11:36 -0400
Received: by mail-wm0-f47.google.com with SMTP id t79so96581027wmt.0
        for <netdev@vger.kernel.org>; Thu, 03 Nov 2016 05:11:35 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1478099398-21639-1-git-send-email-paulb@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 02, 2016 at 05:09:58PM +0200, Paul Blakey wrote:
> Remove left over usage from removal of eth_type argument.
> 
> Fixes: 488b41d020fb ('tc: flower no need to specify the ethertype')
> Signed-off-by: Paul Blakey <paulb@mellanox.com>

Reviewed-by: Simon Horman <simon.horman@netronome.com>
