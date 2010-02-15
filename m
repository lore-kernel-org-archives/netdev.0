From: jamal <hadi@cyberus.ca>
Subject: Re: [net-next-2.6 PATCH 1/7] xfrm: introduce basic mark
 infrastructure
Date: Mon, 15 Feb 2010 12:14:33 -0500
Message-ID: <1266254073.6776.109.camel@bigi>
References: <xfrm-mark-net-next>
	 <1266160732-946-1-git-send-email-hadi@cyberus.ca>
	 <1266160732-946-2-git-send-email-hadi@cyberus.ca>
	 <4B796B70.2050102@trash.net> <1266253235.6776.90.camel@bigi>
	 <4B797F09.5050207@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: timo.teras@iki.fi, herbert@gondor.apana.org.au,
	davem@davemloft.net, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f200.google.com ([209.85.210.200]:41842 "EHLO
	mail-yx0-f200.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755829Ab0BOROf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Feb 2010 12:14:35 -0500
Received: by yxe38 with SMTP id 38so3541712yxe.4
        for <netdev@vger.kernel.org>; Mon, 15 Feb 2010 09:14:34 -0800 (PST)
In-Reply-To: <4B797F09.5050207@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-02-15 at 18:06 +0100, Patrick McHardy wrote:

> One related feature which would be nice to have is the ability
> to use marks for xfrm tunnel routing. But I'm not sure we can
> do this in a backwards compatible way.

I take it policy routing by mark is insufficient.
If you have time, can you give me an example setup description of that
and why it would be hard to be backward-compat?
If there's anything i can do in these patches to help, I will be more
than happy to.

cheers,
jamal

