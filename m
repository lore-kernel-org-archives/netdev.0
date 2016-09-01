From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] mpls: get rid of trivial returns
Date: Thu, 01 Sep 2016 10:14:58 -0700 (PDT)
Message-ID: <20160901.101458.1009667830626592956.davem@davemloft.net>
References: <20160901085107.3ab81729@xeon-e3>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rshearma@brocade.com, roopa@cumulusnetworks.com,
        simon.horman@netronome.com, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39552 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752096AbcIAWCV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2016 18:02:21 -0400
In-Reply-To: <20160901085107.3ab81729@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Thu, 1 Sep 2016 08:51:07 -0700

> return at end of function is useless.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Applied.
