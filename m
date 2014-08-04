From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] random32: improvements to prandom_bytes
Date: Mon, 04 Aug 2014 11:41:46 -0700 (PDT)
Message-ID: <20140804.114146.2155043446693665715.davem@davemloft.net>
References: <1406837476-13776-1-git-send-email-dborkman@redhat.com>
	<20140731.222804.1403723639172562683.davem@davemloft.net>
	<53DF56F1.4020701@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org,
	akinobu.mita@gmail.com
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44137 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751744AbaHDSly (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Aug 2014 14:41:54 -0400
In-Reply-To: <53DF56F1.4020701@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Mon, 04 Aug 2014 11:48:33 +0200

> Akinobu and I also tested this patch with the above fix included,
> and it runs through the 3 relevant test cases _without_ any errors
> on the nandsim device (simulator for MTD devs):

On one endianness only perhaps?
