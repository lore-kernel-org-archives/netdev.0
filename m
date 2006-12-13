From: David Miller <davem@davemloft.net>
Subject: Re: [patch sungem] improved locking
Date: Tue, 12 Dec 2006 20:03:34 -0800 (PST)
Message-ID: <20061212.200334.59657088.davem@davemloft.net>
References: <5cac192f0611290256l7067ce21r39881486f6e21289@mail.gmail.com>
	<5cac192f0611291437g26fefebdocdacbb0cd2aa2fdd@mail.gmail.com>
	<1165979533.11914.114.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.lemoine@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60937
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932559AbWLMEDf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Dec 2006 23:03:35 -0500
To: benh@kernel.crashing.org
In-Reply-To: <1165979533.11914.114.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Wed, 13 Dec 2006 14:12:13 +1100

> David, could that be the pause stuff not working properly ?

It could be, but if the tg3 says flow control is up in the kernel logs
things ought to be OK.
