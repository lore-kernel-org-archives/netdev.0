From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] liquidio: add debug error messages to report
 command timeout
Date: Tue, 21 Mar 2017 17:43:38 -0700 (PDT)
Message-ID: <20170321.174338.769718934673601203.davem@davemloft.net>
References: <20170317182308.GA2319@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        ricardo.farrington@cavium.com
To: felix.manlunas@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59236 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932772AbdCVAoc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 20:44:32 -0400
In-Reply-To: <20170317182308.GA2319@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felix Manlunas <felix.manlunas@cavium.com>
Date: Fri, 17 Mar 2017 11:23:08 -0700

> From: Rick Farrington <ricardo.farrington@cavium.com>
> 
> Add timeout error message in lio_process_ordered_list().  Add host failure
> status in existing error message in if_cfg_callback().
> 
> Signed-off-by: Rick Farrington <ricardo.farrington@cavium.com>
> Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>

Applied.
