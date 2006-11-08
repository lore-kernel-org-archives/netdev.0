From: Tim Chen <tim.c.chen@linux.intel.com>
Subject: Re: 2.6.19-rc1: Volanomark slowdown
Date: Wed, 08 Nov 2006 14:32:08 -0800
Message-ID: <1163025128.10806.217.camel@localhost.localdomain>
References: <1162924354.10806.172.camel@localhost.localdomain>
	 <1163001318.3138.346.camel@laptopd505.fenrus.org>
	 <20061108162955.GA4364@suse.de>
	 <1163011132.10806.189.camel@localhost.localdomain>
	 <20061108221028.GA16889@suse.de>
	 <1163023652.10806.203.camel@localhost.localdomain>
	 <20061108150007.49eaea68@freekitty>
Reply-To: tim.c.chen@linux.intel.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Olaf Kirch <okir@suse.de>, Arjan van de Ven <arjan@infradead.org>,
	linux-kernel@vger.kernel.org, davem@sunset.davemloft.net,
	kuznet@ms2.inr.ac.ru, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.89]:63347 "EHLO
	fmsmga101.fm.intel.com") by vger.kernel.org with ESMTP
	id S1161709AbWKHXVh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Nov 2006 18:21:37 -0500
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20061108150007.49eaea68@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-11-08 at 15:00 -0800, Stephen Hemminger wrote:

> 
> Optimizing for loopback is perversion; perversion can be fun but it gets
> to be a obsession then it's sick.
> 

It is not my intention to optimize for this case, but rather to
detect change in kernel behavior.

That's why in my original mail I ask if increase in ACKs could
cause problem for any real application.  

Tim
