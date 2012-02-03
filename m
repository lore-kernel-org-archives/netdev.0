From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [RFC PATCH V4 02/13] netback: add module unload function.
Date: Fri, 3 Feb 2012 11:27:45 +0000
Message-ID: <1328268465.7388.5.camel@leeds.uk.xensource.com>
References: <1328201363-13915-1-git-send-email-wei.liu2@citrix.com>
	 <1328201363-13915-3-git-send-email-wei.liu2@citrix.com>
	 <1328202524.11534.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1328203710.5553.94.camel@leeds.uk.xensource.com>
	 <1328204936.13262.4.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1328212761.28964.77.camel@dagon.hellion.org.uk>
	 <1328214866.2480.18.camel@edumazet-laptop>
	 <1328215821.13189.24.camel@dagon.hellion.org.uk>
	 <CAP=VYLq3CZBjC2ecOdGqAejN5Atu9kd1HovhQwc-eVk-q8ArJA@mail.gmail.com>
	 <1328251092.13189.29.camel@dagon.hellion.org.uk>
	 <1328253910.2480.41.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <wei.liu2@citrix.com>, Ian Campbell <Ian.Campbell@citrix.com>,
	"Paul Gortmaker" <paul.gortmaker@windriver.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([62.200.22.115]:57723 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754814Ab2BCL10 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2012 06:27:26 -0500
In-Reply-To: <1328253910.2480.41.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-02-03 at 07:25 +0000, Eric Dumazet wrote:
> 
> We are stuck right now with a bug introduced in 2.6.39, (IP redirects),
> and because fix was done in 3.1, we are unable to provide a fix fo
> stable 3.0 kernel.
> 
> Something that takes 15 minutes to fix now, can take several days of
> work later.
> 
> 
> 

You're right.

Will stick Ian's patch in front of my next series. Thanks for your
effort in reviewing.



Wei.
