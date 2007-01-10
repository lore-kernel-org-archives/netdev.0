From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH] d80211: Select CRYPTO_ECB when enabler d80211.
Date: Wed, 10 Jan 2007 21:14:00 +0100
Message-ID: <20070110211400.2bb4d75b@griffin.suse.cz>
References: <459FD5C2.6070007@kpnplanet.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:36366 "EHLO mail.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S965082AbXAJUOE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Jan 2007 15:14:04 -0500
To: Gertjan van Wingerde <gwingerde@kpnplanet.nl>
In-Reply-To: <459FD5C2.6070007@kpnplanet.nl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 06 Jan 2007 18:00:50 +0100, Gertjan van Wingerde wrote:
> The d80211 stack uses ECB mode block ciphers for the WEP implementation.
> Make sure that support for CRYPTO_ECB is in the kernel when the d80211
> stack is enabled (just like the other crypto algorithms).

Applied to my tree, thanks for the patch.

 Jiri

-- 
Jiri Benc
SUSE Labs
