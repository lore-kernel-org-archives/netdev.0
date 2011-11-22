From: Jun Zhao <mypopydev@gmail.com>
Subject: Re: [patch v2 1/1] fix error handle in ip_mc_add_src()
Date: Wed, 23 Nov 2011 07:08:21 +0800
Message-ID: <1322003302.4977.3.camel@barry.pixelworks.com>
References: <1321891516.14281.62.camel@barry.pixelworks.com>
	 <20111122.162237.1924632736368263053.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	dlstevens@us.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:55495 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752726Ab1KVXKQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2011 18:10:16 -0500
Received: by iage36 with SMTP id e36so806191iag.19
        for <netdev@vger.kernel.org>; Tue, 22 Nov 2011 15:10:15 -0800 (PST)
In-Reply-To: <20111122.162237.1924632736368263053.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-11-22 at 16:22 -0500, David Miller wrote:
> From: Jun Zhao <mypopydev@gmail.com>
> Date: Tue, 22 Nov 2011 00:05:16 +0800
> 
> > from: Jun Zhao <mypopydev@gmail.com>
> > 
> > When add sources to interface failure, need to roll back the sfcount[MODE] 
> > to before state. We need to match it corresponding. 
> > 
> > Acked-by: David L Stevens <dlstevens@us.ibm.com>
> > Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
> > Signed-off-by: Jun Zhao <mypopydev@gmail.com>
> 
> Please use an appropriate prefix in your subject line after the
> closing "]" bracket.  For example, something like "ipv4: " for this
> specific patch is fine.
> 
> Your patch has also been corrupted by your email client, it turned tab
> characters into spaces amongst other things.  Please correct this,
> email a test patch to yourself, and make absolutely sure you are able
> to successfully apply it before you retry submitting your fix here.
> 
> Thank you.

Ok, I will double-check this according to your comments, after that,
re-submit the patch, Tks.
