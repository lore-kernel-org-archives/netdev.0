From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: Difference between Net and Net-Next
Date: Thu, 28 Mar 2013 07:28:14 +0100
Message-ID: <20130328062814.GC2511@netboy.at.omicron.at>
References: <loom.20130327T180118-245@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jim Baxter <jim_baxter@mentor.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f175.google.com ([209.85.215.175]:34864 "EHLO
	mail-ea0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751253Ab3C1G2Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Mar 2013 02:28:24 -0400
Received: by mail-ea0-f175.google.com with SMTP id r16so1044095ead.6
        for <netdev@vger.kernel.org>; Wed, 27 Mar 2013 23:28:23 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <loom.20130327T180118-245@post.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 27, 2013 at 05:02:28PM +0000, Jim Baxter wrote:
> How do you decide which changes should go into "net" and which ones go into "net-
> next"?
> 
> At a guess I would think bug fixes are in "net" and feature changes into
> "net-next" but it is not obvious from the commit log.

I'll go out on a limb and try to explain this:

net-next - changes for the next merge window
net      - bug fixes and cleanups for the current release candidate

HTR (hope thats right),
Richard
