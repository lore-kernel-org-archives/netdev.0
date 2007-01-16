From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [IPROUTE 01/05]: Use tc_calc_xmittime where appropriate
Date: Tue, 16 Jan 2007 12:02:44 +0100
Message-ID: <20070116110244.GB1003@ff.dom.local>
References: <20070116085611.GA1003@ff.dom.local> <45ACA6B6.1090902@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, shemminger@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from poczta.o2.pl ([193.17.41.142]:59008 "EHLO poczta.o2.pl"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750771AbXAPLAh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Jan 2007 06:00:37 -0500
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <45ACA6B6.1090902@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 16, 2007 at 11:19:34AM +0100, Patrick McHardy wrote:
...
> Right, this changes it from long (tc_core_usec2tick) to unsigned
> int. It doesn't make any difference though, ... 

... if we count out reading_time_2tick, of course.

Jarek P.
