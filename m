From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: rt_cache leak 2.6.18
Date: Tue, 17 Feb 2009 20:10:59 -0800
Message-ID: <20090217201059.558411a1@extreme>
References: <3496.64.46.62.42.1234920235.squirrel@webmail.imagen.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Hector Herrera" <mail4hh@imagen.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:60574 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751238AbZBRELB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Feb 2009 23:11:01 -0500
In-Reply-To: <3496.64.46.62.42.1234920235.squirrel@webmail.imagen.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 17 Feb 2009 17:23:55 -0800 (PST)
"Hector Herrera" <mail4hh@imagen.ca> wrote:

> Hello,
> 
> I'm debugging an rt_cache leak in 2.6.18 and I would like to view the
> memory contents of the leaked memory slab with the hopes that if I knew
> which routes are being leaked then I would know which network traffic to
> collect to be able to reproduce the leak in a test environment.
> 
> I would appreciate any suggestions you could give me with regards to how
> to go about doing this (searching google didn't turn out anything too
> helpful).
> 
> Thank you,
> 
> Hector
> 

That was 2 1/2 years ago! If you want to do software archeology, they you
really have to do it yourself. Otherwise, please confirm problem on more
recent version.
