From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] ip route: add mpls multipath support
Date: Tue, 9 Feb 2016 09:19:22 -0800
Message-ID: <20160209091922.6187a5e7@xeon-e3>
References: <1454891296-20147-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ebiederm@xmission.com, rshearma@brocade.com
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:34725 "EHLO
	mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752830AbcBIRTJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Feb 2016 12:19:09 -0500
Received: by mail-pf0-f174.google.com with SMTP id x65so11101457pfb.1
        for <netdev@vger.kernel.org>; Tue, 09 Feb 2016 09:19:09 -0800 (PST)
In-Reply-To: <1454891296-20147-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun,  7 Feb 2016 16:28:16 -0800
Roopa Prabhu <roopa@cumulusnetworks.com> wrote:

> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> This patch adds support to add mpls multipath
> routes.
> 
> example:
> ip -f mpls route add 100 \
> 	nexthop as 200 via inet 10.1.1.2 dev swp1 \
> 	nexthop as 700 via inet 10.1.1.6 dev swp2
> 
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>

Applied
