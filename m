From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: [PATCH iproute2] ip link: Fix crash on older kernels when show
 VF dev
Date: Fri, 9 Jan 2015 21:06:56 +0200
Message-ID: <20150109190656.GA25275@angus-think.lan>
References: <1420824351-23450-1-git-send-email-vadim4j@gmail.com>
 <20150109175557.GF31810@gandi.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vadim Kochan <vadim4j@gmail.com>, netdev@vger.kernel.org
To: William Dauchy <william@gandi.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f43.google.com ([209.85.215.43]:40009 "EHLO
	mail-la0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751400AbbAITRW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2015 14:17:22 -0500
Received: by mail-la0-f43.google.com with SMTP id s18so16094034lam.2
        for <netdev@vger.kernel.org>; Fri, 09 Jan 2015 11:17:21 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20150109175557.GF31810@gandi.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 09, 2015 at 06:55:57PM +0100, William Dauchy wrote:
> On Jan09 19:25, Vadim Kochan wrote:
> > From: Vadim Kochan <vadim4j@gmail.com>
> > 
> > The issue was caused that ifla_vf_rate does not exist on
> > older kernels and should be checked if it exists as nested attr.
> > 
> > Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
> > Reported-by: William Dauchy <william@gandi.net>
> > Tested-by: William Dauchy <william@gandi.com>
> 
> gandi.net actually ;)
> 
> Thanks,
> 

Sorry, I will re-send.
