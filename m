From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 1/1] net/ipv4: Enable flow-based ECMP
Date: Tue, 28 Jul 2015 23:32:34 -0700 (PDT)
Message-ID: <20150728.233234.1713531356449283264.davem@davemloft.net>
References: <CALx6S361R1UeEECQn9vFDCS-wi_StoV6mekqgSK-0t-0NPvWEA@mail.gmail.com>
	<55B7F202.5050503@alliedtelesis.co.nz>
	<20150729061148.GB18456@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Richard.Laing@alliedtelesis.co.nz, tom@herbertland.com,
	netdev@vger.kernel.org, jmorris@namei.org
To: mkubecek@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56482 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751683AbbG2Gch (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2015 02:32:37 -0400
In-Reply-To: <20150729061148.GB18456@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Kubecek <mkubecek@suse.cz>
Date: Wed, 29 Jul 2015 08:11:48 +0200

> Having both sysctl and per-route attribute would be perfect, of
> course.

+1
