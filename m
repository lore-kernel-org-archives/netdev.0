From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCHv4] iproute2: generalize VXLAN forwarding tables
Date: Fri, 3 May 2013 13:21:36 -0700
Message-ID: <20130503132136.1d361d8b@nehalam.linuxnetplumber.net>
References: <201305011321.r41DLM0j002746@lab1.dls>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
To: David L Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f48.google.com ([209.85.210.48]:58272 "EHLO
	mail-da0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762084Ab3ECUVx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 May 2013 16:21:53 -0400
Received: by mail-da0-f48.google.com with SMTP id h32so945471dak.21
        for <netdev@vger.kernel.org>; Fri, 03 May 2013 13:21:52 -0700 (PDT)
In-Reply-To: <201305011321.r41DLM0j002746@lab1.dls>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 01 May 2013 09:21:22 -0400
David L Stevens <dlstevens@us.ibm.com> wrote:

> 
> iproute2 patch to generalize VXLAN forwarding tables
> 
> This is the iproute2 support allowing an administrator to specify alternate
> ports, vnis and outgoing interfaces for VXLAN device forwarding tables.
> 
> Changes since v3: changed NDA_PORT to be 16-bit network byte order to match
> 	changed byte-order/size in the VXLAN driver.
> 
> Signed-Off-By: David L Stevens <dlstevens@us.ibm.com>

Applied.
