From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: Re: sfc: Replace LRO with GRO
Date: Mon, 19 Jan 2009 14:12:47 -0800
Message-ID: <1232403167.5539.1.camel@brick>
References: <20090115042422.GB29658@gondor.apana.org.au>
	 <20090118.215027.46669769.davem@davemloft.net>
	 <1232376006.3004.19.camel@achroite>
	 <20090119.132929.108799868.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, Stephen Rothwell <sfr@canb.auug.org.au>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.169]:32582 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753853AbZASWMt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2009 17:12:49 -0500
Received: by wf-out-1314.google.com with SMTP id 27so3421403wfd.4
        for <netdev@vger.kernel.org>; Mon, 19 Jan 2009 14:12:49 -0800 (PST)
In-Reply-To: <20090119.132929.108799868.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2009-01-19 at 13:29 -0800, David Miller wrote:
> From: Ben Hutchings <bhutchings@solarflare.com>
> > 
> > Please could you push this and other GRO changes for .30 to
> > net-next-2.6?
> 
> All of Herbert's bug fixes are going into net-2.6, and that's
> where they will stay.
> 
> I haven't published my net-next-2.6 tree at all, because
> Stephen Rothwell hasn't stated that such content is
> OK yet for his -next tree.

I thought Stephen had stated that anytime _after_ -rc1 was released was
OK for new material destined for the next release.

If you're waiting for an explicit OK, I don't think it will forthcoming.

Harvey

