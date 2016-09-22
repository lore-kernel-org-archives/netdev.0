From: Ido Schimmel <idosch@idosch.org>
Subject: Re: [patch net-next 2/6] fib: introduce FIB info offload flag helpers
Date: Thu, 22 Sep 2016 08:14:49 +0300
Message-ID: <20160922051449.GB24119@splinter>
References: <1474458794-5512-1-git-send-email-jiri@resnulli.us>
 <1474458794-5512-3-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
        eladr@mellanox.com, yotamg@mellanox.com, nogahf@mellanox.com,
        ogerlitz@mellanox.com, roopa@cumulusnetworks.com,
        nikolay@cumulusnetworks.com, linville@tuxdriver.com,
        andy@greyhouse.net, f.fainelli@gmail.com, dsa@cumulusnetworks.com,
        jhs@mojatatu.com, vivien.didelot@savoirfairelinux.com,
        andrew@lunn.ch, ivecera@redhat.com, kaber@trash.net,
        john@phrozen.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:35962 "EHLO
        out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750770AbcIVFOw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 01:14:52 -0400
Content-Disposition: inline
In-Reply-To: <1474458794-5512-3-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 21, 2016 at 01:53:10PM +0200, Jiri Pirko wrote:
> From: Jiri Pirko <jiri@mellanox.com>
> 
> These helpers are to be used in case someone offloads the FIB entry. The
> result is that if the entry is offloaded to at least one device, the
> offload flag is set.
> 
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Reviewed-by: Ido Schimmel <idosch@mellanox.com>

Thanks
