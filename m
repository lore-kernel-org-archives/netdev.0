From: David Miller <davem@davemloft.net>
Subject: Re: Socket buffer sizes with autotuning
Date: Mon, 12 May 2008 21:02:02 -0700 (PDT)
Message-ID: <20080512.210202.158182011.davem@davemloft.net>
References: <d1c2719f0805122056ib4c1af7pfa7f95f6e38c7e32@mail.gmail.com>
	<20080512.205837.215391489.davem@davemloft.net>
	<d1c2719f0805122100u7e550820xff6fcdbc1e538948@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hkchu@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60004
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752039AbYEMECI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2008 00:02:08 -0400
In-Reply-To: <d1c2719f0805122100u7e550820xff6fcdbc1e538948@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Jerry Chu" <hkchu@google.com>
Date: Mon, 12 May 2008 21:00:08 -0700

> Does xchg() return the old value? (Can't find any comments on it.)

Yes, otherwise it wouldn't be very useful.
