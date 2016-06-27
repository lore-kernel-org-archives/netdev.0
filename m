From: Stephen Hemminger <shemming@brocade.com>
Subject: Re: [iproute PATCH] man: ip-address, ip-link: Document 'type' quirk
Date: Mon, 27 Jun 2016 10:51:22 -0700
Message-ID: <20160627105122.42cc454e@xeon-e3>
References: <1466763263-1994-1-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:32119 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751944AbcF0RvP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2016 13:51:15 -0400
In-Reply-To: <1466763263-1994-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 24 Jun 2016 12:14:23 +0200
Phil Sutter <phil@nwl.cc> wrote:

> This covers the fact that calling 'ip {link|addr} show type foobar' does
> not return an error.
> 
> Signed-off-by: Phil Sutter <phil@nwl.cc>

Applied
