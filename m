From: David Miller <davem@davemloft.net>
Subject: Re: [NET] Add proc file to display the state of all qdiscs.
Date: Wed, 02 Sep 2009 01:30:02 -0700 (PDT)
Message-ID: <20090902.013002.181288977.davem@davemloft.net>
References: <20090902081429.GB4878@ff.dom.local>
	<4A9E2CC7.1010103@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, cl@linux-foundation.org, kaber@trash.net,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43206
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752864AbZIBI3r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2009 04:29:47 -0400
In-Reply-To: <4A9E2CC7.1010103@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 02 Sep 2009 10:28:55 +0200

> What naming convention should we choose for multiqueue devices ?

We could give an index field to multiple root qdiscs assigned
to a device.
