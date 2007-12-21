From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] Fix lost export-dynamic
Date: Fri, 21 Dec 2007 09:17:13 -0800
Message-ID: <20071221091713.7273277f@deepthought>
References: <200712171606.38546.vgusev@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Vitaliy Gusev <vgusev@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:60138 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750946AbXLURR6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2007 12:17:58 -0500
In-Reply-To: <200712171606.38546.vgusev@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 17 Dec 2007 16:06:38 +0300
Vitaliy Gusev <vgusev@openvz.org> wrote:

> get_link_kind() fails for statically linked modules (vlan, veth, etc.) if "ip" 
> was linked without "export-dynamic".
> 
> Signed-off-by: Vitaliy Gusev <vgusev@openvz.org>
> 

applied thanks

-- 
Stephen Hemminger <stephen.hemminger@vyatta.com>
