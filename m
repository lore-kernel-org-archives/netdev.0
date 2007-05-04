From: David Howells <dhowells@redhat.com>
Subject: Re: How to find I/F to destination
Date: Fri, 04 May 2007 14:04:20 +0100
Message-ID: <5802.1178283860@redhat.com>
References: <20070504125438.GA5439@2ka.mipt.ru>  <5484.1178282928@redhat.com>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:57502 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755120AbXEDNEg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 May 2007 09:04:36 -0400
In-Reply-To: <20070504125438.GA5439@2ka.mipt.ru> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:

> 	err = __ip_route_output_key(rp, flp);

Is there any way to get at this without having to link against the ipv4
module?

David
