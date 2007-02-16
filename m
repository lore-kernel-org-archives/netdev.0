From: James Morris <jmorris@namei.org>
Subject: Re: ip_append_page and the socket send buffer
Date: Fri, 16 Feb 2007 16:27:50 -0500 (EST)
Message-ID: <Pine.LNX.4.64.0702161627340.5602@d.namei>
References: <45D60DED.7050709@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Elad Lahav <elad_lahav@users.sourceforge.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail8.sea5.speakeasy.net ([69.17.117.10]:47771 "EHLO
	mail8.sea5.speakeasy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946273AbXBPV1x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Feb 2007 16:27:53 -0500
In-Reply-To: <45D60DED.7050709@users.sourceforge.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 16 Feb 2007, Elad Lahav wrote:

> I wrote a function that is equivalent to udp_sendmsg, but uses ip_append_page
> to attach data to an skb. The function is implemented as follows:

Why?

Where is the code?


-- 
James Morris
<jmorris@namei.org>
