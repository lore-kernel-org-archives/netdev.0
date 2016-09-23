From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next 0/2] improvements to SSN and TSN handling
Date: Fri, 23 Sep 2016 06:55:41 -0400 (EDT)
Message-ID: <20160923.065541.716099111392174272.davem@davemloft.net>
References: <cover.1474405559.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        nhorman@tuxdriver.com, vyasevich@gmail.com, David.Laight@ACULAB.COM
To: marcelo.leitner@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50846 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934472AbcIWKzw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Sep 2016 06:55:52 -0400
In-Reply-To: <cover.1474405559.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Date: Tue, 20 Sep 2016 18:19:12 -0300

> First patch fixes a potential issue made visible by the second one
> noticed by David Laight and is a preparation for the next one.
> 
> The second patch changes how SSN, TSN and ASCONF serials are compared so
> they can use typecheck() and are more like time_before() macro.

Series applied, thanks.
