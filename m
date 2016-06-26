From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] qed/qede: Tunnel hardware GRO support
Date: Sun, 26 Jun 2016 15:53:50 -0400 (EDT)
Message-ID: <20160626.155350.85882752040798916.davem@davemloft.net>
References: <CAKgT0UdDt6H8ix6U7n_uPjodkXYuxviZjSKWQRaXu2_qWWEL+A@mail.gmail.com>
	<CO2PR11MB0088C4DEAFEE71B0D865DB33972C0@CO2PR11MB0088.namprd11.prod.outlook.com>
	<576B08A2.8080603@hpe.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Yuval.Mintz@qlogic.com, alexander.duyck@gmail.com,
	manish.chopra@qlogic.com, netdev@vger.kernel.org,
	Ariel.Elior@qlogic.com, tom@herbertland.com, hannes@redhat.com
To: rick.jones2@hpe.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37327 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751330AbcFZTxy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jun 2016 15:53:54 -0400
In-Reply-To: <576B08A2.8080603@hpe.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Jones <rick.jones2@hpe.com>
Date: Wed, 22 Jun 2016 14:52:34 -0700

> To get that disabled, one must also get the bnx2x module loaded with
> "disable-tpa=1" so the Linux stack GRO gets used instead.

And people wonder why I'm difficult about module parameters in
drivers....
