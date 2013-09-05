From: Dave Jones <davej@redhat.com>
Subject: Re: Add missing braces in bnx2x:bnx2x_link_initialize
Date: Thu, 5 Sep 2013 14:27:50 -0400
Message-ID: <20130905182750.GB7309@redhat.com>
References: <20130905034658.GA12717@redhat.com>
 <20130905.142117.1916319107625842387.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22008 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753922Ab3IES2A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Sep 2013 14:28:00 -0400
Content-Disposition: inline
In-Reply-To: <20130905.142117.1916319107625842387.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 05, 2013 at 02:21:17PM -0400, David Miller wrote:
 > 
 > David, I'm going to apply your missing braces patches, but I'm really irritated
 > that I've told you at least 5 times to put proper subsystem prefixes into
 > your subject lines.
 > 
 > For this I'd use "bnx2x: ", for the TCP patch I'd use "tcp: " and for the
 > CAIF change I'd use "caif: "

I knew I'd forget something..

 > Please get into the habit of doing this, or I'm going to push back on you
 > to correct this instead of fixing it up automatically for you every time,
 > since the latter really is not scalable.

Sure thing.

thanks,

	Dave
