From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Re : Re : Bug in using inet_lookup ()
Date: Thu, 15 Nov 2007 13:12:28 +0300
Message-ID: <20071115101228.GC16458@2ka.mipt.ru>
References: <256275.33084.qm@web26104.mail.ukl.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Nj A <nj_a83@yahoo.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:41746 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754638AbXKOKMF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Nov 2007 05:12:05 -0500
Content-Disposition: inline
In-Reply-To: <256275.33084.qm@web26104.mail.ukl.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 14, 2007 at 04:47:22PM +0000, Nj A (nj_a83@yahoo.fr) wrote:
> By setting the ID of the ingress device to the inet_lookup() to 0, the machine reboots automatically.
> Setting proc/sys/kernel/panic* to non zero values dosn't help more..

Sorry, I did not understand?
You mean after you provide zero to inet_lookup() instead of device id it
strted to reboot?

-- 
	Evgeniy Polyakov
