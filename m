From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [PATCH net-2.6.26][VLAN]: Reduce memory consumed by vlan_group-s.
Date: Wed, 26 Mar 2008 18:12:07 +0300
Message-ID: <47EA67C7.1050202@openvz.org>
References: <47CC2ACF.6080903@openvz.org> <47E2731A.3090401@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:55941 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750727AbYCZPMI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Mar 2008 11:12:08 -0400
In-Reply-To: <47E2731A.3090401@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Patrick.

> Its an improvement, so I've applied it, thanks.

I noticed you merged some netfilter patches to net-2.6.26, but what 
are your plans about merging vlan-related patches to it? 

I ask because I have some patches with vlan netnsization, but I can't
just send them to net-2.6.26, since they will produce conflicts with 
this patch and maybe more you have for vlan, which are not at Dave yet.

Thanks,
Pavel
