From: David Miller <davem@davemloft.net>
Subject: Re: pull-request: mac80211 2017-09-07
Date: Thu, 07 Sep 2017 09:41:21 -0700 (PDT)
Message-ID: <20170907.094121.72570273753562618.davem@davemloft.net>
References: <20170907070939.3658-1-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57478 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752263AbdIGQlY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 7 Sep 2017 12:41:24 -0400
In-Reply-To: <20170907070939.3658-1-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Thu,  7 Sep 2017 09:09:38 +0200

> During my long absence some things have accumulated, but there wasn't
> actually all that much that could've gone into the last cycle, and a
> fix or two was taken care of by others.
> 
> The most important thing here is probably the deadlock fix that a few
> people have run into on 4.13, but that was only identified now, and
> perhaps the 40 MHz fix from Emmanuel that helps avoid iwlwifi firmware
> crashes.
> 
> Please pull and let me know if there's any problem.

Pulled, thanks.
