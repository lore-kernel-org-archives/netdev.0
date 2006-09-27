From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] skge: fiber support
Date: Wed, 27 Sep 2006 11:02:23 -0700
Message-ID: <20060927110223.7d55e50d@freekitty>
References: <20060815131852.GP2900@mathom.us>
	<20060921153939.739947ab@dxpl.pdx.osdl.net>
	<20060926154459.GA6030@mathom.us>
	<20060927172644.GA14294@mathom.us>
	<20060927103415.21bdccc9@freekitty>
	<20060927175900.GC6030@mathom.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:50608 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1030518AbWI0SCf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2006 14:02:35 -0400
To: Michael Stone <mstone@mathom.us>
In-Reply-To: <20060927175900.GC6030@mathom.us>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 27 Sep 2006 13:59:02 -0400
Michael Stone <mstone@mathom.us> wrote:

> On Wed, Sep 27, 2006 at 10:34:15AM -0700, Stephen Hemminger wrote:
> >That's surprising, memory leak? dropped packets?
> 
> I'm open to suggestions on debugging it. It seems fairly repeatable 
> about half an hour after startup.
> 
> Mike Stone

I'll run a longer test with SK card (Ebay) to E1000.

-- 
Stephen Hemminger <shemminger@osdl.org>
