From: Jarod Wilson <jarod@redhat.com>
Subject: Re: [PATCH net-next] sfc: check MTU against minimum threshold
Date: Tue, 6 Sep 2016 17:31:28 -0400
Message-ID: <20160906213128.GG33916@redhat.com>
References: <20160902170742.GA17677@redhat.com>
 <09fc2c3f-744b-41e5-5801-96fa80cd6ad5@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dave Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-net-drivers@solarflare.com
To: Bert Kenward <bkenward@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:36496 "EHLO
        mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932538AbcIFVbe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2016 17:31:34 -0400
Received: by mail-wm0-f53.google.com with SMTP id b187so85714246wme.1
        for <netdev@vger.kernel.org>; Tue, 06 Sep 2016 14:31:33 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <09fc2c3f-744b-41e5-5801-96fa80cd6ad5@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 06, 2016 at 05:50:00PM +0100, Bert Kenward wrote:
> Reported-by: Ma Yuying <yuma@redhat.com>
> Suggested-by: Jarod Wilson <jarod@redhat.com>
> Signed-off-by: Bert Kenward <bkenward@solarflare.com>

Works for me, until we can get some dialog going about possible
centralization (or not) of MTU checking, so we don't have this slightly
crazy proliferation of *_MIN_MTU anymore. :)

Reviewed-by: Jarod Wilson <jarod@redhat.com>

-- 
Jarod Wilson
jarod@redhat.com
