From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Speed-up pfifo_fast lookup using a bitmap
Date: Mon, 17 Aug 2009 19:03:43 -0700 (PDT)
Message-ID: <20090817.190343.49229178.davem@davemloft.net>
References: <20090814132458.27518.65144.sendpatchset@localhost.localdomain>
	<20090814213643.GA3179@ami.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, kaber@trash.net, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53984
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754013AbZHRCDc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Aug 2009 22:03:32 -0400
In-Reply-To: <20090814213643.GA3179@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Fri, 14 Aug 2009 23:36:43 +0200

> I definitely can't see a reason to make this variable public, and
> prefer the private (v2) version (which still lacks a changelog, btw).

I'm fine with patch v2, but yes it needs to be properly submitted
with a real changelog before I can apply it :-)
