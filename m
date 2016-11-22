From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCHv2 net-next 00/11] Start adding support for mv88e6390
Date: Tue, 22 Nov 2016 12:21:00 -0500
Message-ID: <87inrfzb0j.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me>
References: <1479767225-13789-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:33668 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932372AbcKVRVD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2016 12:21:03 -0500
In-Reply-To: <1479767225-13789-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Andrew Lunn <andrew@lunn.ch> writes:

> This is the first patchset implementing support for the mv88e6390
> family.  This is a new generation of switch devices and has numerous
> incompatible changes to the registers. These patches allow the switch
> to the detected during probe, and makes the statistics unit work.
>
> These patches are insufficient to make the mv88e6390 functional. More
> patches will follow.
>
> v2:
>   Move stats code into global1
>   Change DT compatible string to mv88e6190
>   Fixed mv88e6351 stats which v1 had broken

Thanks Andrew!

For what it's worth:

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>


    Vivien
