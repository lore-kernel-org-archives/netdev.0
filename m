From: David Miller <davem@davemloft.net>
Subject: Re: [patch net 0/4] mlxsw: spectrum: Various fixes
Date: Wed, 12 Jul 2017 08:16:53 -0700 (PDT)
Message-ID: <20170712.081653.2173301523941887907.davem@davemloft.net>
References: <20170712071255.1232-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, mlxsw@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55250 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752735AbdGLPQz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Jul 2017 11:16:55 -0400
In-Reply-To: <20170712071255.1232-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Wed, 12 Jul 2017 09:12:51 +0200

> First patch adds a missing rollback in error path. Second patch prevents
> a use-after-free during IPv4 route replace. Last two patches fix warnings
> from static checkers.

Series applied, thanks.
