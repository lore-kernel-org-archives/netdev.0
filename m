From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix tcp splice length
Date: Mon, 26 Jan 2009 21:29:57 -0800 (PST)
Message-ID: <20090126.212957.04247470.davem@davemloft.net>
References: <200901270512.n0R5CLXB019113@darkside.asicdesigners.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dada1@cosmosbay.com
To: dm@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57651
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754330AbZA0FaA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 00:30:00 -0500
In-Reply-To: <200901270512.n0R5CLXB019113@darkside.asicdesigners.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dimitris Michailidis <dm@chelsio.com>
Date: Mon, 26 Jan 2009 21:12:21 -0800

>     Fix length tcp_splice_data_recv passes to skb_splice_bits.

Eric, please review this.
