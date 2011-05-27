From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCHv4] ethtool: Added FW dump support
Date: Fri, 27 May 2011 21:47:44 +0100
Message-ID: <1306529264.2759.19.camel@bwh-desktop>
References: <1305240515-29237-1-git-send-email-anirban.chakraborty@qlogic.com>
	 <DA112A8D-1B47-4826-AC58-772C88FF21FC@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:53191 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751277Ab1E0Urs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 May 2011 16:47:48 -0400
In-Reply-To: <DA112A8D-1B47-4826-AC58-772C88FF21FC@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-05-27 at 13:31 -0700, Anirban Chakraborty wrote:
> On May 12, 2011, at 3:48 PM, Anirban Chakraborty wrote:
> 
> > Added support to take FW dump via ethtool.
> > 
> > Changes since v3:
> > Updated documentation for ethtool_dump data structure
> > 
> > Changes from v2:
> > Folded get dump flag and data into one option
> > Added man page support
> > 
> > Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
> > ---
> > ethtool-copy.h |   24 +++++++++++-
> > ethtool.8.in   |   23 +++++++++++
> > ethtool.c      |  112 +++++++++++++++++++++++++++++++++++++++++++++++++++++++-
> > 3 files changed, 156 insertions(+), 3 deletions(-)
> > 
> > diff --git a/ethtool-copy.h b/ethtool-copy.h
> > <snip>
> 
> Ben, 
> 
> I was wondering if you'd applied the above patch. Thanks.

No, but it's at the front of my queue and I'll probably get to it next
week.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

