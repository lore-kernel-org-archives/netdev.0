From: David Howells <dhowells@redhat.com>
Subject: Re: How to find I/F to destination
Date: Fri, 04 May 2007 14:06:44 +0100
Message-ID: <5875.1178284004@redhat.com>
References: <5802.1178283860@redhat.com>  <20070504125438.GA5439@2ka.mipt.ru> <5484.1178282928@redhat.com>
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:58070 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755131AbXEDNGz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 May 2007 09:06:55 -0400
In-Reply-To: <5802.1178283860@redhat.com> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Howells <dhowells@redhat.com> wrote:

> > 	err = __ip_route_output_key(rp, flp);
> 
> Is there any way to get at this without having to link against the ipv4
> module?

Ah, nevermind.  ipv4 can't be a module.

David
