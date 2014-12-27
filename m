From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: [PATCH iproute2] tc class: Show classes as ASCII graph
Date: Sat, 27 Dec 2014 20:14:28 +0200
Message-ID: <20141227181428.GA8668@angus-think.lan>
References: <1419552606-21516-1-git-send-email-vadim4j@gmail.com>
 <20141227101916.0ff9659d@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vadim Kochan <vadim4j@gmail.com>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f48.google.com ([74.125.82.48]:36439 "EHLO
	mail-wg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751079AbaL0SYi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Dec 2014 13:24:38 -0500
Received: by mail-wg0-f48.google.com with SMTP id y19so16179847wgg.7
        for <netdev@vger.kernel.org>; Sat, 27 Dec 2014 10:24:37 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20141227101916.0ff9659d@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 27, 2014 at 10:19:16AM -0800, Stephen Hemminger wrote:
> On Fri, 26 Dec 2014 02:10:06 +0200
> Vadim Kochan <vadim4j@gmail.com> wrote:
> 
> > From: Vadim Kochan <vadim4j@gmail.com>
> > 
> > Added new '-g[raph]' option which shows classes in the graph view.
> > 
> > Meanwhile only generic stats info output is supported.
> > 
> 
> Applied, please send a man page update as well.
Sure, I did not update man page to do not conflict with a patch series
where new '-netns' option is added.

Thanks,
