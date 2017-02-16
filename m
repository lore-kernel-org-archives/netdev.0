From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [patch net-next RFC 0/8] Add support for pipeline debug (dpipe)
Date: Thu, 16 Feb 2017 17:11:50 +0100
Message-ID: <20170216161150.GC17550@lunn.ch>
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
Received: from vps0.lunn.ch ([178.209.37.122]:42008 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932254AbdBPQL4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 16 Feb 2017 11:11:56 -0500
Content-Disposition: inline
In-Reply-To: <1487258564-3775-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 16, 2017 at 04:22:36PM +0100, Jiri Pirko wrote:
> From: Jiri Pirko <jiri@mellanox.com>
> 
> Arkadi says:

Hi Jiri, Arkadi

It is not mentioned here, but i assume you have a followup patchset
which extends the devlink command to enumerate what tables are
available and to print them?

What i seem to be missing is headers in uapi which links kernel and
userspace together. There are lots of enums defined, but few seem to
be exported to user space for the table parser/printer to use.

Hopefully it will be more obvious when the user space patches are
available.

Thanks
	Andrew
