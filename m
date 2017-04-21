From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 00/11][pull request] 10GbE Intel Wired LAN Driver
 Updates 2017-04-20
Date: Fri, 21 Apr 2017 14:18:09 -0400 (EDT)
Message-ID: <20170421.141809.1159225304098548850.davem@davemloft.net>
References: <20170421015029.18994-1-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36436 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1036880AbdDUS1b (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 14:27:31 -0400
In-Reply-To: <20170421015029.18994-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 20 Apr 2017 18:50:18 -0700

> John adds XDP support (yeah!) for ixgbe.

As excited and eager as I am about this, I want to see the build regression
for PAGE_SIZE>=8192 fixed before I pull this.

Thanks.
