From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/5] UDP memory accounting and limitation (take 7)
Date: Tue, 13 Nov 2007 20:32:11 -0800 (PST)
Message-ID: <20071113.203211.26204733.davem@davemloft.net>
References: <473A5FD6.5010209@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, satoshi.oshima.fk@hitachi.com,
	herbert@gondor.apana.org.au, billfink@mindspring.com,
	andi@firstfloor.org, johnpol@2ka.mipt.ru,
	shemminger@linux-foundation.org, yoshfuji@linux-ipv6.org,
	yumiko.sugita.yf@hitachi.com
To: haoki@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60777
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755862AbXKNEcM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2007 23:32:12 -0500
In-Reply-To: <473A5FD6.5010209@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hideo AOKI <haoki@redhat.com>
Date: Tue, 13 Nov 2007 21:39:18 -0500

> I updated UDP memory accounting and limitation patch set.

I'm dropping this for now, please resubmit after the expensive
divide is fixed.
