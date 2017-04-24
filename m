From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] flower: add MPLS matching support
Date: Mon, 24 Apr 2017 14:32:57 -0400 (EDT)
Message-ID: <20170424.143257.1003081554810761464.davem@davemloft.net>
References: <1492894367-11637-1-git-send-email-benjamin.lahaise@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bcrl@kvack.org
To: benjamin.lahaise@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55966 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1760184AbdDXSc7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 14:32:59 -0400
In-Reply-To: <1492894367-11637-1-git-send-email-benjamin.lahaise@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin LaHaise <benjamin.lahaise@netronome.com>
Date: Sat, 22 Apr 2017 16:52:45 -0400

> From: Benjamin LaHaise <bcrl@kvack.org>
> 
> This patch series adds support for parsing MPLS flows in the flow dissector
> and the flower classifier.  Each of the MPLS TTL, BOS, TC and Label fields
> can be used for matching.
> 
> v2: incorporate style feedback, move #defines to linux/include/mpls.h
> Note: this omits Jiri's request to remove tabs between the type and 
> field names in struct declarations.  This would be inconsistent with 
> numerous other struct definitions.

Series applied, but in the future:

1) Put the "v2", "v3", whatever in the inital [PATCH xxx] bracketed
   part of the subject line, otherwise it ends up in the GIT commit
   message header line and that's not desired.

2) Please cut it with these double signoffs, and add an appropriate
   entry to the email aliases file.

Thanks.
