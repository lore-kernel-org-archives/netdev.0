From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH RFC] [1/9] Core module symbol namespaces code and intro.
Date: Thu, 22 Nov 2007 19:17:37 +0100
Message-ID: <200711221917.38334.ak@suse.de>
References: <20071122343.446909000@suse.de> <20071122120110.GA17441@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	sam@ravnborg.org, rusty@rustcorp.com.au
To: "Arnaldo Carvalho de Melo" <acme@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.suse.de ([195.135.220.2]:59270 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752255AbXKVSV7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Nov 2007 13:21:59 -0500
In-Reply-To: <20071122120110.GA17441@ghostprotocols.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> Creating the DCCP and its congestion control infrastructure (CCID)
> module namespaces is now on my TODO list. :-)

My original patchkit had DCCP actually done, but I ran into some problem
while forward porting and disabled it again. But should be reasonably
easy to resurrect.

-Andi
