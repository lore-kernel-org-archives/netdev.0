From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] generalize VXLAN forwarding tables
Date: Wed, 6 Mar 2013 10:50:52 -0800
Message-ID: <20130306105052.05f7b9ca@nehalam.linuxnetplumber.net>
References: <201302281927.r1SJQEmF024241@lab1.dls>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org
To: David L Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f169.google.com ([209.85.210.169]:47259 "EHLO
	mail-ia0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752799Ab3CFSu4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Mar 2013 13:50:56 -0500
Received: by mail-ia0-f169.google.com with SMTP id j5so7801907iaf.28
        for <netdev@vger.kernel.org>; Wed, 06 Mar 2013 10:50:56 -0800 (PST)
In-Reply-To: <201302281927.r1SJQEmF024241@lab1.dls>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 28 Feb 2013 14:26:14 -0500
David L Stevens <dlstevens@us.ibm.com> wrote:

> 
> This is the iproute2 support allowing an administrator to specify alternate
> ports, vnis and outgoing interfaces for VXLAN device forwarding tables.
> 
> Signed-Off-By: David L Stevens <dlstevens@us.ibm.com>

Resubmit patch when the kernel support (in neighbour.h) is upstream in Linus's kernel.
