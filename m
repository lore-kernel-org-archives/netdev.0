From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vxlan: force user to set port value
Date: Wed, 15 May 2013 15:40:28 -0700 (PDT)
Message-ID: <20130515.154028.15755797576037157.davem@davemloft.net>
References: <20130515134818.18b2c710@nehalam.linuxnetplumber.net>
	<20130515.144730.888918410336115705.davem@davemloft.net>
	<20130515150433.1eb4c73a@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dlstevens@us.ibm.com, amwang@redhat.com, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34755 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752982Ab3EOWkb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 May 2013 18:40:31 -0400
In-Reply-To: <20130515150433.1eb4c73a@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Wed, 15 May 2013 15:04:33 -0700

> I made a mistake in the initial implementation using that value and
> every user for time immemorial has to suffer.

We don't break userland, period.

You don't have to explain to me how unfortunate this situation is,
I understand.

But that doesn't give us a license to break things on people.
