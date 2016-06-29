From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [iproute PATCH 1/2] ip-address: Support filtering by slave type,
 too
Date: Tue, 28 Jun 2016 19:19:03 -0600
Message-ID: <b4ca924e-41f9-840e-6d31-dfe3ccd5e66e@cumulusnetworks.com>
References: <1467119237-12544-1-git-send-email-phil@nwl.cc>
 <1467119237-12544-2-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>, Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:35653 "EHLO
	mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752448AbcF2BT1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jun 2016 21:19:27 -0400
Received: by mail-pf0-f178.google.com with SMTP id c2so12098997pfa.2
        for <netdev@vger.kernel.org>; Tue, 28 Jun 2016 18:19:03 -0700 (PDT)
In-Reply-To: <1467119237-12544-2-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/28/16 7:07 AM, Phil Sutter wrote:
> This patch allows to query all interfaces enslaved to a bridge or bond
> using the following syntax:

works for vrf's too.
