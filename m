From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: [PATCH iproute2 3/3] ip netns: Delete all netns
Date: Wed, 7 Jan 2015 19:36:40 +0200
Message-ID: <20150107173640.GA19586@angus-think.lan>
References: <1420628662-9930-1-git-send-email-vadim4j@gmail.com>
 <1420628662-9930-4-git-send-email-vadim4j@gmail.com>
 <54AD5458.6000400@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vadim Kochan <vadim4j@gmail.com>, netdev@vger.kernel.org
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f179.google.com ([209.85.217.179]:61142 "EHLO
	mail-lb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753899AbbAGRrJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2015 12:47:09 -0500
Received: by mail-lb0-f179.google.com with SMTP id z11so1483224lbi.10
        for <netdev@vger.kernel.org>; Wed, 07 Jan 2015 09:47:05 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <54AD5458.6000400@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 07, 2015 at 10:44:24AM -0500, Brian Haley wrote:
> On 01/07/2015 06:04 AM, Vadim Kochan wrote:
> > From: Vadim Kochan <vadim4j@gmail.com>
> > 
> > Allow delete all namespace names by:
> > 
> >     $ ip netns del all
> 
> So I can still create a namespace called 'all', but can't exec in it or delete
> it independently with this change.  Perhaps you need to block that as well?
> Unless there's some other patch I'm missing?
> 
> -Brian
Hm, I did not take it into account ...
I will look if I can find another way ...

Thanks,
