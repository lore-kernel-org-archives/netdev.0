From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v7 0/4] net: Introduce protodown flag.
Date: Wed, 15 Jul 2015 14:01:16 -0700 (PDT)
Message-ID: <20150715.140116.83712075690751658.davem@davemloft.net>
References: <1436906602-2958-1-git-send-email-anuradhak@cumulusnetworks.com>
	<CAE4R7bC2WPDfJiT7Av8YYUybvc0D1cakKBgDsL+mystM33guFw@mail.gmail.com>
	<20150715162434.GE588@gospo.home.greyhouse.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfeldma@gmail.com, anuradhak@cumulusnetworks.com,
	netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	wkok@cumulusnetworks.com
To: gospo@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32793 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753426AbbGOVBR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jul 2015 17:01:17 -0400
In-Reply-To: <20150715162434.GE588@gospo.home.greyhouse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Gospodarek <gospo@cumulusnetworks.com>
Date: Wed, 15 Jul 2015 12:24:35 -0400

> If it is switchdev-only that would prevent people from using commodity
> hardware (classic servers + NICs) from being able to build something
> similar to what can be done with rocker.

Agreed, this isn't switchdev specific at all.
