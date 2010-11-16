From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] ethtool: Add support for vlan accleration.
Date: Tue, 16 Nov 2010 23:14:09 +0000
Message-ID: <1289949249.30433.10.camel@localhost>
References: <1288059734-12916-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: jgarzik@redhat.com, netdev@vger.kernel.org,
	David Dillow <dave@thedillows.org>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:33161 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932215Ab0KPXOM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Nov 2010 18:14:12 -0500
In-Reply-To: <1288059734-12916-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-10-25 at 19:22 -0700, Jesse Gross wrote:
> The kernel now has support for enabling and disabling vlan
> acceleration, similar to other forms of offloading.  This
> adds the complementary userspace support.

Applied.

I had an earlier change that renamed 'off_flags_unwanted' to
'off_flags_mask', so I adjusted your patch accordingly.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

