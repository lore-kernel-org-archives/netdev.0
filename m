From: Andrew Morton <akpm@osdl.org>
Subject: Re: IP1000 gigabit nic driver
Date: Wed, 3 May 2006 05:43:00 -0700
Message-ID: <20060503054300.b5e8b95f.akpm@osdl.org>
References: <20060427142939.GA31473@fargo>
	<20060427185627.GA30871@electric-eye.fr.zoreil.com>
	<445144FF.4070703@cantab.net>
	<20060428075725.GA18957@fargo>
	<84144f020604280358ie9990c7h399f4a5588e575f8@mail.gmail.com>
	<20060428113755.GA7419@fargo>
	<Pine.LNX.4.58.0604281458110.19801@sbz-30.cs.Helsinki.FI>
	<1146306567.1642.3.camel@localhost>
	<20060429122119.GA22160@fargo>
	<1146342905.11271.3.camel@localhost>
	<1146389171.11524.1.camel@localhost>
	<44554ADE.8030200@cantab.net>
	<1146475901.11271.3.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: dvrabel@cantab.net, romieu@fr.zoreil.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	david@pleyades.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:61852 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965186AbWECMnU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 May 2006 08:43:20 -0400
To: Pekka Enberg <penberg@cs.helsinki.fi>
In-Reply-To: <1146475901.11271.3.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 01 May 2006 12:31:40 +0300
Pekka Enberg <penberg@cs.helsinki.fi> wrote:

> [PATCH] IP1000 Gigabit Ethernet device driver
> 
> This is a cleaned up fork of the IP1000A device driver:
> 
>   http://www.icplus.com.tw/driver-pp-IP1000A.html

Please remember that to merge this we'll need a signed-off-by from the
original developers.  (That's not very gplish, but such is life).


