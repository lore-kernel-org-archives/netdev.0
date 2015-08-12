From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 net-next 1/2] iplink: bridge: add ageing_time,
 stp_state and priority when showing attributes
Date: Wed, 12 Aug 2015 09:14:36 -0700
Message-ID: <20150812091436.4ae3c3d7@urahara>
References: <1439297784-1962-1-git-send-email-razor@blackwall.org>
	<1439297784-1962-2-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: Nikolay Aleksandrov <razor@blackwall.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:35017 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752850AbbHLQOd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2015 12:14:33 -0400
Received: by pacgr6 with SMTP id gr6so17488361pac.2
        for <netdev@vger.kernel.org>; Wed, 12 Aug 2015 09:14:33 -0700 (PDT)
In-Reply-To: <1439297784-1962-2-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 11 Aug 2015 15:56:23 +0300
Nikolay Aleksandrov <razor@blackwall.org> wrote:

> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> 
> When showing bridge attributes, show also ageing_time, stp_state and
> priority if available.
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

This doesn't need anything that is not already in 4.2-rc
therefore applied to master.
