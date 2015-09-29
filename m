From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] sctp: Fix SCTP deadlock
Date: Mon, 28 Sep 2015 21:03:57 -0700 (PDT)
Message-ID: <20150928.210357.1723865763239680947.davem@davemloft.net>
References: <1443111307-16503-1-git-send-email-kheiss@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	nhorman@tuxdriver.com, vyasevich@gmail.com
To: kheiss@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52896 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751388AbbI2ED6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 00:03:58 -0400
In-Reply-To: <1443111307-16503-1-git-send-email-kheiss@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Karl Heiss <kheiss@gmail.com>
Date: Thu, 24 Sep 2015 12:15:05 -0400

> These patches fix a deadlock during accept() of an SCTP connection.
> 
> The first patch fixes whitespace issues.
> 
> The second patch actually fixes the deadlock race.

Seems reasonable, series applied, thanks.
