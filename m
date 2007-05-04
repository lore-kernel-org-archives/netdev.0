From: David Howells <dhowells@redhat.com>
Subject: Re: How to find I/F to destination
Date: Fri, 04 May 2007 14:08:15 +0100
Message-ID: <5910.1178284095@redhat.com>
References: <20070504125438.GA5439@2ka.mipt.ru>  <5484.1178282928@redhat.com>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:58543 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755142AbXEDNI1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 May 2007 09:08:27 -0400
In-Reply-To: <20070504125438.GA5439@2ka.mipt.ru> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Should route_get_raw() release the rtable if gets back?

David
