From: David Dillow <dave@thedillows.org>
Subject: Re: [PATCH 19/19] netdev: convert bulk of drivers to netdev_tx_t
Date: Tue, 01 Sep 2009 12:21:47 -0400
Message-ID: <1251822107.24125.5.camel@lap75545.ornl.gov>
References: <20090901055039.824876937@vyatta.com>
 <20090901055130.375691503@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from emroute1.ornl.gov ([160.91.4.119]:44317 "EHLO emroute1.ornl.gov"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753964AbZIAQVu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Sep 2009 12:21:50 -0400
Received: from emroute1.ornl.gov ([127.0.0.1])
 by emroute1.ornl.gov (PMDF V6.4 #31561)
 with ESMTP id <0KPA00GQMW4DCI@emroute1.ornl.gov> for netdev@vger.kernel.org;
 Tue, 01 Sep 2009 12:21:49 -0400 (EDT)
In-reply-to: <20090901055130.375691503@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2009-08-31 at 22:50 -0700, Stephen Hemminger wrote:
>  drivers/net/typhoon.c                |    2 +-

For what it's worth (ie, not much), typhoon bits
Acked-by: David Dillow <dave@thedillows.gov>
