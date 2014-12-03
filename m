From: vadim4j@gmail.com
Subject: Re: [PATCH iproute2] ip monitor: Fixed printing timestamp few times
Date: Wed, 3 Dec 2014 19:41:53 +0200
Message-ID: <20141203174153.GA12034@angus-think.wlc.globallogic.com>
References: <1417389262-25189-1-git-send-email-vadim4j@gmail.com>
 <20141203091338.2d32de2c@urahara>
 <20141203171126.GA7381@angus-think.wlc.globallogic.com>
 <20141203094731.4d310fc5@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:64246 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751183AbaLCRvh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2014 12:51:37 -0500
Received: by mail-wi0-f170.google.com with SMTP id bs8so33979156wib.5
        for <netdev@vger.kernel.org>; Wed, 03 Dec 2014 09:51:36 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20141203094731.4d310fc5@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 03, 2014 at 09:47:31AM -0800, Stephen Hemminger wrote:
> On Wed, 3 Dec 2014 19:11:26 +0200
> vadim4j@gmail.com wrote:
> 
> > I think it was caused by RTM_NEWNDUSEROPT which was sent by router.
> > So in this case the message will be skipped with printed timestamp.
> 
> Can that be decoded? it might be useful.

Sorry, you mean how it can be reproduced by clean scenario?
