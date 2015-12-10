From: Stephen Hemminger <shemming@brocade.com>
Subject: Re: [PATCH iproute] ila: Add support for ILA lwtunnels
Date: Thu, 10 Dec 2015 09:05:09 -0800
Message-ID: <20151210090509.0cbc5329@xeon-e3>
References: <1448924248-4025991-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:40249 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752998AbbLJRFQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2015 12:05:16 -0500
In-Reply-To: <1448924248-4025991-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 30 Nov 2015 14:57:28 -0800
Tom Herbert <tom@herbertland.com> wrote:

> This patch:
>  - Adds a utility function for parsing a 64 bit address
>  - Adds a utility function for converting a 64 bit address to ASCII
>  - Adds and ILA encap type in lwt tunnels
> 
> Signed-off-by: Tom Herbert <tom@herbertland.com>

Looks good applied.

You might want to get some of that 64 bit stuff into libmnl as well.
