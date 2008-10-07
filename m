From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [IPROUTE]: Fix up "ip link" help text
Date: Tue, 7 Oct 2008 23:18:20 +0200
Message-ID: <20081007231820.3caf072a@speedy>
References: <48EB7D76.7050004@trash.net>
	<200810072206.03062.arekm@maven.pl>
	<48EBCE59.3080401@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Arkadiusz Miskiewicz <arekm@maven.pl>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:47012 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753490AbYJGVS1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Oct 2008 17:18:27 -0400
In-Reply-To: <48EBCE59.3080401@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 07 Oct 2008 23:02:17 +0200
Patrick McHardy <kaber@trash.net> wrote:

> Arkadiusz Miskiewicz wrote:
> > Runtime dependand help doesn't look sane. Help should always show all possible 
> > options/command while trying to use unsupported option should display error 
> > message.
> >   
> 
> That makes sense. But don't complain to me about the quality
> of the error messages afterwards please :)
> 
> 

I had a better message set in works. will merge mine and patrick's
