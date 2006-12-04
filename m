From: James Morris <jmorris@namei.org>
Subject: Re: RFC: consistent disable_xfrm behaviour
Date: Mon, 4 Dec 2006 10:05:50 -0500 (EST)
Message-ID: <XMMS.LNX.4.64.0612041005260.4314@d.namei>
References: <457437EA.7000406@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail7.sea5.speakeasy.net ([69.17.117.9]:55230 "EHLO
	mail7.sea5.speakeasy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936954AbWLDPFw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Dec 2006 10:05:52 -0500
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <457437EA.7000406@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 4 Dec 2006, Patrick McHardy wrote:

> disable_xfrm - BOOLEAN
> 
>         Disable IPSEC encryption on this interface, whatever the policy
> 
> Opinions?

Looks good to me, wonder what the original rationale was, though.



-- 
James Morris
<jmorris@namei.org>
