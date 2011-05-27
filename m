From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Subject: Re: [PATCHv4] ethtool: Added FW dump support
Date: Fri, 27 May 2011 13:31:51 -0700
Message-ID: <DA112A8D-1B47-4826-AC58-772C88FF21FC@qlogic.com>
References: <1305240515-29237-1-git-send-email-anirban.chakraborty@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>
To: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe004.messaging.microsoft.com ([65.55.88.14]:15771 "EHLO
	TX2EHSOBE009.bigfish.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752796Ab1E0Ub7 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 May 2011 16:31:59 -0400
In-Reply-To: <1305240515-29237-1-git-send-email-anirban.chakraborty@qlogic.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On May 12, 2011, at 3:48 PM, Anirban Chakraborty wrote:

> Added support to take FW dump via ethtool.
> 
> Changes since v3:
> Updated documentation for ethtool_dump data structure
> 
> Changes from v2:
> Folded get dump flag and data into one option
> Added man page support
> 
> Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
> ---
> ethtool-copy.h |   24 +++++++++++-
> ethtool.8.in   |   23 +++++++++++
> ethtool.c      |  112 +++++++++++++++++++++++++++++++++++++++++++++++++++++++-
> 3 files changed, 156 insertions(+), 3 deletions(-)
> 
> diff --git a/ethtool-copy.h b/ethtool-copy.h
> <snip>

Ben, 

I was wondering if you'd applied the above patch. Thanks.

Anirban



