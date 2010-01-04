From: jamal <hadi@cyberus.ca>
Subject: Re: regression in socket match caused by "net: Fix RPF to work
 with policy routing"
Date: Mon, 04 Jan 2010 05:13:42 -0500
Message-ID: <1262600022.3568.2.camel@bigi>
References: <20100104100417.GA7699@verge.net.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: NetDEV list <netdev@vger.kernel.org>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f192.google.com ([209.85.221.192]:64857 "EHLO
	mail-qy0-f192.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753261Ab0ADKNp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2010 05:13:45 -0500
Received: by qyk30 with SMTP id 30so6913062qyk.33
        for <netdev@vger.kernel.org>; Mon, 04 Jan 2010 02:13:44 -0800 (PST)
In-Reply-To: <20100104100417.GA7699@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Simon,


On Mon, 2010-01-04 at 21:04 +1100, Simon Horman wrote:
> Hi Jamal,
> 
> the patch "net: Fix RPF to work with policy routing",
> which was added between 2.6.32-rc5 and rc6 seems to
> cause a regression when using the socket match.
> 
> In particular I'm using IP_TRANSPARENT as detailed
> in Documentation/networking/tproxy.txt with the following
> rules:

Try latest tree - should be resolved.

cheers,
jamal

