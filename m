From: "Denys Fedoryshchenko" <denys@visp.net.lb>
Subject: Re: DoS by cat /proc/net/ip_conntrack ?
Date: Sat, 8 Mar 2008 16:24:34 +0200
Message-ID: <20080308142254.M64724@visp.net.lb>
References: <20080306134037.M70019@visp.net.lb> <Pine.LNX.4.64.0803061449220.23263@bizon.gios.gov.pl> <47D28601.4080106@gmail.com> <47D28786.80600@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
Cc: Krzysztof Oledzki <olel@ans.pl>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:59790 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753369AbYCHOYq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Mar 2008 09:24:46 -0500
In-Reply-To: <47D28786.80600@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For me personally, i think must be as a rule, that _READING_ must not hang 
whole system by consuming all resources (router becoming completely 
unreachable and blocking all traffic passing thru it). It can hang console, 
current program, but not crash router.

On Sat, 08 Mar 2008 13:33:10 +0100, Jarek Poplawski wrote
> Jarek Poplawski wrote, On 03/08/2008 01:26 PM:
> ....
> 
> > I think, Denys is concerned about some other, maybe too curious users
> > if they can read this?
> 
> OOPS! I see it's root only...
> 
> Then only their curiosity could be dangerous here!
> 
> Sorry,
> Jarek P.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

