From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [patch net-next RFC 0/8] Add support for pipeline debug (dpipe)
Date: Thu, 16 Feb 2017 18:04:46 +0100
Message-ID: <20170216170446.GF17550@lunn.ch>
References: <1487258564-3775-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, arkadis@mellanox.com,
        idosch@mellanox.com, mlxsw@mellanox.com, jhs@mojatatu.com,
        ivecera@redhat.com, roopa@cumulusnetworks.com,
        f.fainelli@gmail.com, vivien.didelot@savoirfairelinux.com,
        john.fastabend@gmail.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:42125 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754770AbdBPREv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 16 Feb 2017 12:04:51 -0500
Content-Disposition: inline
In-Reply-To: <1487258564-3775-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 16, 2017 at 04:22:36PM +0100, Jiri Pirko wrote:
> From: Jiri Pirko <jiri@mellanox.com>

Hi Jiri, Arkadi

Just to make sure we are all on the same page here:

This purely RFC. It is not intended for the merge window starting next
week?

This is a new binary API, something we have to live with forever. So i
think before it gets merged into a Linus kernel, we need time to think
about all the different sorts of tables we want to dump, what sort of
fields they have, and can we represent them using this API. That is
going to take some time.

      Andrew
