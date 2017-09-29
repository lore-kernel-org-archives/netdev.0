From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: RFC iproute2 doc files
Date: Fri, 29 Sep 2017 10:28:47 -0700
Message-ID: <20170929102847.224dbd08@xeon-e3>
References: <20170920081159.321e426b@xeon-e3>
        <20170928071803.GA15815@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:56155 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751224AbdI2R2z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 29 Sep 2017 13:28:55 -0400
Received: by mail-pg0-f54.google.com with SMTP id b11so145783pgn.12
        for <netdev@vger.kernel.org>; Fri, 29 Sep 2017 10:28:55 -0700 (PDT)
In-Reply-To: <20170928071803.GA15815@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 28 Sep 2017 09:18:04 +0200
Simon Horman <simon.horman@netronome.com> wrote:

> On Wed, Sep 20, 2017 at 08:11:59AM -0700, Stephen Hemminger wrote:
> > I noticed that the iproute man pages are up to date but the LaTex documentation
> > is very out of date. Rarely updated since the Linux 2.2 days.
> > 
> > Either someone needs to do a massive editing job on them, or they should just
> > be dropped. My preference would be to just drop everything in the doc/ directory.
> > The current versions are so old, they can't be helping.  
> 
> FWIW, removing stale documentation sounds sensible to me.

I removed all the stale ones. The file ip-cref was occasionally updated.
