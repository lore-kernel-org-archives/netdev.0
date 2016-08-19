From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] ipv6: fix stuck RA-derived route in container
 after migration with criu
Date: Thu, 18 Aug 2016 21:09:14 -0700 (PDT)
Message-ID: <20160818.210914.2117594939784536395.davem@davemloft.net>
References: <1471355943-21288-1-git-send-email-ayourtch@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ayourtch@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41842 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754259AbcHSEJP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2016 00:09:15 -0400
In-Reply-To: <1471355943-21288-1-git-send-email-ayourtch@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The indentation of both of your patches are incorrect.

You must indent each basic block by a full TAB character.

You must also line up multi-line function calls, such that
the second and subsequent lines start precisely at the first
column after the opennning parenthesis of the function call
itself.  You must use the appropriate number of TAB and
SPC characters necessary to achieve this.
