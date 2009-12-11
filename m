From: David Miller <davem@davemloft.net>
Subject: Re: Custom hardware Qdisc...
Date: Fri, 11 Dec 2009 14:40:21 -0800 (PST)
Message-ID: <20091211.144021.192655356.davem@davemloft.net>
References: <4B228EC0.80105@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ddaney@caviumnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36920
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1761390AbZLKWkP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Dec 2009 17:40:15 -0500
In-Reply-To: <4B228EC0.80105@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Daney <ddaney@caviumnetworks.com>
Date: Fri, 11 Dec 2009 10:26:08 -0800

> Our hardware (Octeon SOC) has fairly flexible packet output queuing
> that can be done completely in hardware.

You haven't described sufficiently what your hardware is
capable of.

Generally, implementing qdiscs specifically to support
hardware features is not how things are handled.

But really we need to know a lot more about the details of your
hardware to make any kind of real suggestions.
