From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH] d80211: select CRC32 functions
Date: Wed, 31 Jan 2007 19:56:58 +0100
Message-ID: <20070131195658.489baa30@griffin.suse.cz>
References: <ep798e$guu$1@sea.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Marcus Better <marcus@better.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:39040 "EHLO mail.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S933334AbXAaS5F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Jan 2007 13:57:05 -0500
In-Reply-To: <ep798e$guu$1@sea.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 24 Jan 2007 10:35:10 +0100, Marcus Better wrote:
> The d80211 stack requires CRC32 functions for the WEP implementation.

Your mail client converts tabs to spaces, please check its settings
next time (and Cc: me and John Linville on d80211 patches).

Applied to my tree, thanks for the patch.

 Jiri

-- 
Jiri Benc
SUSE Labs
