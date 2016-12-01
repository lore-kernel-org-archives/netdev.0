From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next v3 11/12] mlxsw: spectrum_router: Request a
 dump of FIB tables during init
Date: Thu, 01 Dec 2016 15:04:45 -0500 (EST)
Message-ID: <20161201.150445.558407356269727869.davem@davemloft.net>
References: <1480500546-2544-12-git-send-email-jiri@resnulli.us>
        <eb7ddecd-d6b4-dfce-5990-9e933227c862@stressinduktion.org>
        <20161130163229.rkxvuwukgg35ktrx@splinter.mtl.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, jiri@resnulli.us,
        netdev@vger.kernel.org, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, arkadis@mellanox.com,
        ogerlitz@mellanox.com, roopa@cumulusnetworks.com,
        dsa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        andy@greyhouse.net, vivien.didelot@savoirfairelinux.com,
        andrew@lunn.ch, f.fainelli@gmail.com, alexander.h.duyck@intel.com,
        kaber@trash.net
To: idosch@idosch.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43188 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757251AbcLAUEs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 15:04:48 -0500
In-Reply-To: <20161130163229.rkxvuwukgg35ktrx@splinter.mtl.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hannes and Ido,

It looks like we are very close to having this in mergable shape, can
you guys work out this final issue and figure out if it really is
a merge stopped or not?

Thanks.
