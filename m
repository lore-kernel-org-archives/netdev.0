From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: Re: [PATCH] dm9601: warn on invalid mac address
Date: Wed, 07 Jan 2009 09:25:03 +0100
Message-ID: <873afvmskg.fsf@macbook.be.48ers.dk>
References: <20090106091050.GA19316@localhost>
	<87zli4u71i.fsf@macbook.be.48ers.dk>
	<1231242755.3789.9.camel@deadeye.i.decadent.org.uk>
	<20090106.105226.58880881.davem@davemloft.net>
	<20090107045505.GB8071@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, bhutchings@solarflare.com,
	netdev@vger.kernel.org
To: Wu Fengguang <wfg@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.187]:15351 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751880AbZAGIZI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2009 03:25:08 -0500
Received: by nf-out-0910.google.com with SMTP id d3so1016349nfc.21
        for <netdev@vger.kernel.org>; Wed, 07 Jan 2009 00:25:07 -0800 (PST)
In-Reply-To: <20090107045505.GB8071@localhost> (Wu Fengguang's message of "Wed\, 7 Jan 2009 12\:55\:05 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>>>> "Wu" == Wu Fengguang <wfg@linux.intel.com> writes:

 Wu> Thanks for the tip. Here is the updated patch.

 Wu> Thanks,
 Wu> Fengguang
 Wu> ---
 Wu> dm9601: warn on invalid mac address

 Wu> Add warnings on invalid mac address to help disclose/debug problems.

 Wu> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>

Acked-by: Peter Korsgaard <jacmet@sunsite.dk>

-- 
Bye, Peter Korsgaard
