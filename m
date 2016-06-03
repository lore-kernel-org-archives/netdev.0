From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH stable] Set a large MTU on ovs-created tunnel devices
Date: Fri, 03 Jun 2016 11:44:18 -0700 (PDT)
Message-ID: <20160603.114418.907250018461386490.davem@davemloft.net>
References: <CAOZ2QJNufB+4ffEpaab6iWotM_4+PQKVcEorEN9Hckh3NiJaQA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dan.streetman@canonical.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39348 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932389AbcFCSoU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 14:44:20 -0400
In-Reply-To: <CAOZ2QJNufB+4ffEpaab6iWotM_4+PQKVcEorEN9Hckh3NiJaQA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Streetman <dan.streetman@canonical.com>
Date: Fri, 3 Jun 2016 13:49:09 -0400

> Can you queue up these commits for stable?

This stuff doesn't cleanly backport, I tried several times already.

Therfore, someone knowledgable with OVS is going to have to do the
backport, test it, and post it for me to submit.

Thanks.
