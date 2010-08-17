From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5 2/2] macvtap: Implement multiqueue for macvtap driver
Date: Tue, 17 Aug 2010 01:50:16 -0700 (PDT)
Message-ID: <20100817.015016.179951322.davem@davemloft.net>
References: <20100804161552.3814.56839.sendpatchset@krkumar2.in.ibm.com>
	<20100804161559.3814.52060.sendpatchset@krkumar2.in.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arnd@arndb.de, mst@redhat.com, netdev@vger.kernel.org,
	xiaosuo@gmail.com, bhutchings@solarflare.com, therbert@google.com
To: krkumar2@in.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40153
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757215Ab0HQIt6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Aug 2010 04:49:58 -0400
In-Reply-To: <20100804161559.3814.52060.sendpatchset@krkumar2.in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krishna Kumar <krkumar2@in.ibm.com>
Date: Wed, 04 Aug 2010 21:45:59 +0530

> Implement multiqueue facility for macvtap driver. The idea is that
> a macvtap device can be opened multiple times and the fd's can be
> used to register eg, as backend for vhost.

Applied.
