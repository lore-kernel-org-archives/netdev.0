From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [TIPC]: Changed msg_set_bits params type
Date: Sat, 28 Apr 2007 21:24:33 -0700 (PDT)
Message-ID: <20070428.212433.17865830.davem@davemloft.net>
References: <46310443.7090405@ericsson.com>
	<20070426.144521.98863152.davem@davemloft.net>
	<46313AD2.6060809@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	jon.maloy@donjonn.com, per.liden@ericsson.com
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39553
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754569AbXD2EYY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Apr 2007 00:24:24 -0400
In-Reply-To: <46313AD2.6060809@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jon Paul Maloy <jon.maloy@ericsson.com>
Date: Thu, 26 Apr 2007 19:50:42 -0400

> David Miller wrote:
> > Did you actually run sparse to see what warnings this change
> > adds or deletes or are you submitting untested changes?
> >
> >   
> I did, and I am aware that sparse shows several warnings
> for TIPC, which we will have to fix this asap, of course.
> The patched line did not show up in the warning list, which
> along with a full regression test made me conclude that we
> didn't introduce a problem, at least. I see now that it
> didn't cause a warning before the change either, so I was
> probably too quick to try to please people. You can can
> ignore the patch if you want to, but it is safe.

Thanks for clarifying, but your email client corrupted the patch by
mangling the whitespace and adding newlines to break up long lines.

I feel like I write this to somebody every single day, but
could you please email patches to yourself and test that
they actually apply instead of wasting my time like this?
