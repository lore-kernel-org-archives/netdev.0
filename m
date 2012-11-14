From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH V3] wanrouter: Remove it and the drivers that depend on it
Date: Wed, 14 Nov 2012 10:23:39 -0500
Message-ID: <20121114152339.GA22933@windriver.com>
References: <1352846164.17444.16.camel@joe-AO722>
 <20121113.182215.2003568859498195687.davem@davemloft.net>
 <CAP=VYLqiLpVn99bp08gkSQ+jLFiw8T7vsohJ6e+TdzOtyDwKBQ@mail.gmail.com>
 <20121113.204437.197646115673556624.davem@davemloft.net>
 <20121114060759.GA17128@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <joe@perches.com>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:53483 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161044Ab2KNPXz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2012 10:23:55 -0500
Content-Disposition: inline
In-Reply-To: <20121114060759.GA17128@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Re: [PATCH V3] wanrouter: Remove it and the drivers that depend on it] On 14/11/2012 (Wed 01:07) Paul Gortmaker wrote:

> [Re: [PATCH V3] wanrouter: Remove it and the drivers that depend on it] On 13/11/2012 (Tue 20:44) David Miller wrote:
> 
> > 
> > Paul, you can't have HTML content to the list and one of your MIME
> > sections was HTML, so it was rejected by vger's filters.
> > 
> > Please repost with the HTML stuff removed.
> 
> Ah crap.  I'd replied via gmail ; today and occasionally in the past as
> a convenient short cut when not reading netdev with a "normal" MUA.  And
> this is not the 1st time gmail has randomly decided to be "helpful" by
> mangling plain text like this.  Well, I'll be having no more of that BS.

I was curious to better figure out what triggered this, now that it
isn't 1AM.  It seems the original wasn't plain text, and that gmail
didn't know what else to do with the content from your message when it
arrived as base64 encoded.  It looks like it arrived that way to the
list archivers too, and they failed to do anything sensible with their
copy of your message as well.

http://marc.info/?l=linux-netdev&m=135284894104364&w=2

Paul.
