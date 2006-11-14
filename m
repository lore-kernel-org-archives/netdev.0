From: James Morris <jmorris@namei.org>
Subject: Re: Network virtualization/isolation
Date: Tue, 14 Nov 2006 13:12:20 -0500 (EST)
Message-ID: <XMMS.LNX.4.64.0611141304330.22471@d.namei>
References: <453F8800.9070603@fr.ibm.com> <45408397.8070404@fr.ibm.com>
 <20061026085659.33b4c6dd@freekitty> <200610271134.56830.dim@openvz.org>
 <4541CCF4.4050306@fr.ibm.com> <1162391707.5251.78.camel@jzny2>
 <4559DE01.5090109@fr.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: hadi@cyberus.ca, Dmitry Mishin <dim@openvz.org>,
	Stephen Hemminger <shemminger@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.sea5.speakeasy.net ([69.17.117.4]:29892 "EHLO
	mail2.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S966243AbWKNSMW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Nov 2006 13:12:22 -0500
To: Daniel Lezcano <dlezcano@fr.ibm.com>
In-Reply-To: <4559DE01.5090109@fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 14 Nov 2006, Daniel Lezcano wrote:

> the attached document describes the network isolation at the layer 2 and at
> the layer 3, it presents the pros and cons of the different approaches, their
> common points and the impacted network code.
> I hope it will be helpful :)

What about other network subsystems: xfrm, netfilter, iptables, netlink, 
etc. ?



- James
-- 
James Morris
<jmorris@namei.org>
