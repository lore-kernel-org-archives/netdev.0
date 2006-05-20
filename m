From: pravin b shelar <pravin.shelar@calsoftinc.com>
Subject: Re: [PATCH] Disable multipath cache routing
Date: Sat, 20 May 2006 15:11:20 +0530
Message-ID: <446EE440.8000808@calsoftinc.com>
References: <446ED597.20300@calsoftinc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ravikiran G Thirumalai <kiran@scalex86.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.rgemonitor.com ([64.147.100.114]:58848 "HELO
	inbox2.nyi.net") by vger.kernel.org with SMTP id S932296AbWETJpl
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 May 2006 05:45:41 -0400
To: Chris Wedgwood <cw@f00f.org>
In-Reply-To: <446ED597.20300@calsoftinc.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chris Wedgwood wrote:
> Apparently IP_ROUTE_MULTIPATH_CACHED isn't entirely safe to use and
> will oops the kernel "sooner or later".  The Kconfig comment says
> EXPERIMENTAL but it's not.
>
> Let's go further and mark it BROKEN for now (leaving the comment as-is
> though).  If nobody steps up to resurrect this code we can discuss
> removing it entirely.
I am working on Linux multipath networking and I will like to fix bugs 
related to equal cost multipath caching support.

So can u send me following information about the oops :-

kernel version
config file
routing table setup ( any multipath setup information. e.g. multipath 
algorithm options)
iptable configuration
forwarding information
what was the oops message & what triggered that?

This will help me understand the problem.

Thanks & Regards,
Pravin.

