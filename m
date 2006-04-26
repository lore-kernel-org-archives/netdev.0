From: "David S. Miller" <davem@davemloft.net>
Subject: Re: tune back idle cwnd closing?
Date: Wed, 26 Apr 2006 15:33:22 -0700 (PDT)
Message-ID: <20060426.153322.64811298.davem@davemloft.net>
References: <444E31D9.1010705@psc.edu>
	<20060426.144540.39973302.davem@davemloft.net>
	<444FF132.2080505@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jheffner@psc.edu, zach.brown@oracle.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:18874
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932415AbWDZWdd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Apr 2006 18:33:33 -0400
To: rick.jones2@hp.com
In-Reply-To: <444FF132.2080505@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rick Jones <rick.jones2@hp.com>
Date: Wed, 26 Apr 2006 15:16:18 -0700

> BTW, is the RFC 2681?  I looked that one up on ietf.org and the RFC by 
> that number was a different beast entirely - at least at a very quick 
> glance.

Congestion window validation is the correct RFC.
