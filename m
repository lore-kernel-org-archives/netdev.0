From: David Miller <davem@davemloft.net>
Subject: Re: MPLS for Linux kernel
Date: Mon, 21 Nov 2011 13:29:14 -0500 (EST)
Message-ID: <20111121.132914.1611617296397809001.davem@davemloft.net>
References: <CAFdo_mWE8wMB6QJt_DPi9Ou9OiayzV48URDq7KhKf+q8OfP+Gw@mail.gmail.com>
	<4ECA67C6.2080802@dti2.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: igorm@etf.rs, netdev@vger.kernel.org
To: jorge@dti2.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39444 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751748Ab1KUS3h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2011 13:29:37 -0500
In-Reply-To: <4ECA67C6.2080802@dti2.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Jorge Boncompte [DTI2]" <jorge@dti2.net>
Date: Mon, 21 Nov 2011 16:01:26 +0100

> 	mpls-linux it is not ready to go upstream in my opinion.

And can arguably be implemented in terms of openvswitch and packet scheduler actions.
