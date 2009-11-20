From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 1/1] rps: core implementation
Date: Fri, 20 Nov 2009 15:56:21 -0800 (PST)
Message-ID: <20091120.155621.85045284.davem@davemloft.net>
References: <65634d660911201528k5a07135el471b65fff9dd7c9d@mail.gmail.com>
	<20091120154046.67252d23@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58466
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752851AbZKTX4E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2009 18:56:04 -0500
In-Reply-To: <20091120154046.67252d23@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 20 Nov 2009 15:40:46 -0800

> Sysfs is intentionally one value per file. If you need multiple
> values, then it is the wrong interface.

This is probably right.

