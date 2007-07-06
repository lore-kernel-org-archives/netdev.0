From: Ben Greear <greearb@candelatech.com>
Subject: Re: Does the Netxen driver work?
Date: Fri, 06 Jul 2007 12:21:28 -0700
Message-ID: <468E9638.1020508@candelatech.com>
References: <468E928D.20606@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:58770 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760108AbXGFTVf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jul 2007 15:21:35 -0400
In-Reply-To: <468E928D.20606@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ben Greear wrote:
> Hello!
> 
> I just got some Netxen 10Gbe CX4 adapters and put them into freshly
> updated Fedora 7 64-bit systems.  So far, I am not having much luck.

Ahh, 22-pre-7 seems to work much better..no MSI errors and traffic
is passing fine.

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

