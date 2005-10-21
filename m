From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH,CFT] forcedeth: Remove superflous rx engine stop/start
 cycles.
Date: Fri, 21 Oct 2005 17:24:38 -0400
Message-ID: <43595C96.40300@pobox.com>
References: <432D7B98.8050307@colorfullife.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@oss.sgi.com>, Ayaz Abdulla <AAbdulla@nvidia.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Manfred Spraul <manfred@colorfullife.com>
In-Reply-To: <432D7B98.8050307@colorfullife.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Manfred Spraul wrote:
> Hi all,
> 
> Ayaz noticed that forcedeth stops and restarts the rx engine every 3 
> seconds (link timeout). The attached patch fixes that.
> It also contains a larger whitespace cleanup: I've replaced a few spaces 
> in the comments with tabs.
> 
> Please test it.

Patch OK, but dropped since version 0.44 was dropped.

	Jeff
