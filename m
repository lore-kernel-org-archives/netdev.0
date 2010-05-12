From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] net sched: cleanup and rate limit warning
Date: Wed, 12 May 2010 13:17:54 -0400
Message-ID: <1273684674.16074.0.camel@bigi>
References: <20100511172412.76aff184@nehalam>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:64886 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753448Ab0ELRSI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 May 2010 13:18:08 -0400
Received: by fxm15 with SMTP id 15so314453fxm.19
        for <netdev@vger.kernel.org>; Wed, 12 May 2010 10:18:06 -0700 (PDT)
In-Reply-To: <20100511172412.76aff184@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-05-11 at 17:24 -0700, Stephen Hemminger wrote:
> If the user has a bad classification configuration, and gets a packet
> that goes through too many steps.

Can you pass me the setup which caused this to be hit?

cheers,
jamal

