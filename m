From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: locking api self-test hanging
Date: Wed, 5 Mar 2008 00:23:38 -0800
Message-ID: <20080305002338.c7777808.akpm@linux-foundation.org>
References: <20080304084024.GA3980@ff.dom.local>
	<20080304011050.74f30dd3.akpm@linux-foundation.org>
	<20080304075137.6bbd285f@extreme>
	<20080304.123000.183265831.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org,
	"Rafael J. Wysocki" <rjw@sisk.pl>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:55504 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760518AbYCEIY1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2008 03:24:27 -0500
In-Reply-To: <20080304.123000.183265831.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 04 Mar 2008 12:30:00 -0800 (PST) David Miller <davem@davemloft.net> wrote:

>     [NETPOLL]: Revert two bogus cleanups that broke netconsole.

Seems OK now, thanks.
