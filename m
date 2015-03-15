From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: [PATCH iproute2] man ip-netns: Notice about loose device when do
 'del'
Date: Sun, 15 Mar 2015 13:37:32 +0200
Message-ID: <20150315113732.GA11717@angus-think.lan>
References: <1426417044-6754-1-git-send-email-vadim4j@gmail.com>
 <20150315124704.10365mswq26qzad4@berry.schulz.ip-v6.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vadim Kochan <vadim4j@gmail.com>, netdev@vger.kernel.org
To: Christoph Schulz <develop@kristov.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f170.google.com ([209.85.217.170]:34330 "EHLO
	mail-lb0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752670AbbCOLtM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2015 07:49:12 -0400
Received: by lbbsy1 with SMTP id sy1so15166606lbb.1
        for <netdev@vger.kernel.org>; Sun, 15 Mar 2015 04:49:10 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150315124704.10365mswq26qzad4@berry.schulz.ip-v6.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 15, 2015 at 12:47:04PM +0100, Christoph Schulz wrote:
> Hello!
> 
> Vadim Kochan schrieb am Sun, 15 Mar 2015 12:57:24 +0200:
> 
> >[...]
> >+    $ ip netns pids net0 | xargs | kill
> 
> Shouldn't this be rather
> 
>        $ ip netns pids net0 | xargs kill
> 
> ?
> 
> 
> Regards,
> 
> Christoph Schulz
> 

Yes, thank you :-)
