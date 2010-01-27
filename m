From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] ipv6: Fix possible NULL dereference in icmp6_dst_alloc
Date: Wed, 27 Jan 2010 12:43:31 +0000
Message-ID: <20100127124331.GB15611@ff.dom.local>
References: <20100127103417.GA15206@ff.dom.local> <20100127.030416.179345234.davem@davemloft.net> <20100127121746.GA15611@ff.dom.local> <20100127.042336.52877358.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@vyatta.com, djohnson@starentnetworks.com,
	sakkiped@starentnetworks.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:35173 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754015Ab0A0Mni (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jan 2010 07:43:38 -0500
Received: by bwz27 with SMTP id 27so4459880bwz.21
        for <netdev@vger.kernel.org>; Wed, 27 Jan 2010 04:43:35 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20100127.042336.52877358.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 27, 2010 at 04:23:36AM -0800, David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Wed, 27 Jan 2010 12:17:46 +0000
> 
> > If there is nothing better I still think this patch is right, except
> > better subject (Fix impossible NULL dereference in ... ;-).
> 
> Sorry, I'm not applying it, just like I didn't apply Krishna's similar
> patch he posted earlier today.

I've understood your decision and I'm OK with that; I'm only not sure
there is a better way (comments?) to make this code readable.

Jarek P. 
