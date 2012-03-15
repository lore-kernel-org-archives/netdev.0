From: David Dillow <dave@thedillows.org>
Subject: Re: net next git tree cloning - a problem
Date: Thu, 15 Mar 2012 16:21:52 -0400
Message-ID: <1331842912.23722.6.camel@frustration.ornl.gov>
References: <CAGXs5wVqqD=v3OruOPMewmUdEyMtGEV3RHwsNih+yBeFr5-fvQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
To: Kevin Wilson <wkevils@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta02.ornl.gov ([128.219.14.62]:46062 "EHLO mta02.ornl.gov"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161428Ab2COUbb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Mar 2012 16:31:31 -0400
In-Reply-To: <CAGXs5wVqqD=v3OruOPMewmUdEyMtGEV3RHwsNih+yBeFr5-fvQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-03-15 at 21:51 +0200, Kevin Wilson wrote:
> git log | more
> 
> shows:
> 
> commit cdf485be3a63d1f34293740fb726088c6840ceea
> Author: John Fastabend <john.r.fastabend@intel.com>
> Date:   Sat Feb 11 06:26:00 2012 +0000

git shows the date the patch was written by default, not the date it was
committed to the tree. Use 'git log --pretty=fuller' and you'll see the
commit date was much more recent.
