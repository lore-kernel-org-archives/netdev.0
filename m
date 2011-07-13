From: Geoff Levand <geoff@infradead.org>
Subject: Re: [PATCH 0/3] ps3_gelic: Fix error paths when a tx dma fails
Date: Wed, 13 Jul 2011 15:31:58 -0700
Message-ID: <4E1E1CDE.2060504@infradead.org>
References: <1310501606-829-1-git-send-email-a.heider@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <cbe-oss-dev@lists.ozlabs.org>
To: Andre Heider <a.heider@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe002.messaging.microsoft.com ([216.32.180.12]:59754
	"EHLO VA3EHSOBE002.bigfish.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752367Ab1GMWcR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jul 2011 18:32:17 -0400
In-Reply-To: <1310501606-829-1-git-send-email-a.heider@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andre,

On 07/12/2011 01:13 PM, Andre Heider wrote:
> This series fixes a few bugs for the error paths once a tx dma request
> fails. Without these I either ran into BUG_ON, the device got killed,
> or the kernel crashed.

Thanks for preparing the fixes.  I added them to my ps3-linux
tree and did some quick tests which didn't show any problems.
I'll try to do some more through testing with them sometime
soon.

-Geoff

