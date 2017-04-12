From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] l2tp: constify l2tp_session_get*() and
 l2tp_tunnel_find*()
Date: Wed, 12 Apr 2017 10:44:21 -0400 (EDT)
Message-ID: <20170412.104421.1091186785942558117.davem@davemloft.net>
References: <cover.1491984104.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jchapman@katalix.com
To: g.nault@alphalink.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46032 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751108AbdDLOoX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Apr 2017 10:44:23 -0400
In-Reply-To: <cover.1491984104.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guillaume Nault <g.nault@alphalink.fr>
Date: Wed, 12 Apr 2017 10:05:28 +0200

> Declare parameters of these functions as "const" where possible.

Series applied, thank you.
