From: James Morris <jmorris@namei.org>
Subject: Re: [RFC] [patch 5/6] [Network namespace] ipv4 isolation
Date: Fri, 9 Jun 2006 20:47:19 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0606092046380.17553@d.namei>
References: <20060609210202.215291000@localhost.localdomain>
 <20060609210631.346330000@localhost.localdomain> <Pine.LNX.4.64.0606092022320.17380@d.namei>
 <448A1208.3060602@hp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: dlezcano@fr.ibm.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, serue@us.ibm.com, haveblue@us.ibm.com,
	clg@fr.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.sea5.speakeasy.net ([69.17.117.3]:13005 "EHLO
	mail1.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1030571AbWFJArV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jun 2006 20:47:21 -0400
To: Rick Jones <rick.jones2@hp.com>
In-Reply-To: <448A1208.3060602@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 9 Jun 2006, Rick Jones wrote:

> > I think you'll need to make it so this code has zero impact when not
> > configured.
> 
> Indeed, and over stuff other than loopback too.  I'll not so humbly suggest :)

Yes, I meant the whole lot.



- James
-- 
James Morris
<jmorris@namei.org>
