From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: mlx4+vxlan offload breaks gre tunnels
Date: Thu, 6 Nov 2014 18:30:17 +0200
Message-ID: <545BA219.5030402@mellanox.com>
References: <20141105150448.GA20776@breakpoint.cc> <545A4DB7.5010603@mellanox.com> <20141105165351.GA23131@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Tom Herbert <therbert@google.com>,
	Jesse Gross <jesse@nicira.com>, <amirv@mellanox.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog111.obsmtp.com ([207.126.144.131]:41178 "EHLO
	eu1sys200aog111.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751187AbaKFQam (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2014 11:30:42 -0500
In-Reply-To: <20141105165351.GA23131@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/5/2014 6:53 PM, Florian Westphal wrote:
> Right, the patch below works in my setup as well (until link-add-vxlan,
> that is;)  )

Good, let me look on that little further to see what's the best approach 
here, thanks for the report

Or.
