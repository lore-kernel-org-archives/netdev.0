From: Kevin Hilman <khilman@deeprootsystems.com>
Subject: Re: [PATCH v2 00/10] split out emac cpdma and mdio for reuse
Date: Fri, 03 Sep 2010 10:24:34 -0700
Message-ID: <87eida3fl9.fsf@deeprootsystems.com>
References: <1283465008-18606-1-git-send-email-cyril@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	davinci-linux-open-source@linux.davincidsp.com,
	linux-omap@vger.kernel.org, nsekhar@ti.com, srk@ti.com,
	omar.ramirez@ti.com, bparrot@ti.com
To: Cyril Chemparathy <cyril@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:45964 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756648Ab0ICRYj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Sep 2010 13:24:39 -0400
In-Reply-To: <1283465008-18606-1-git-send-email-cyril@ti.com> (Cyril
	Chemparathy's message of "Thu, 2 Sep 2010 18:03:18 -0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cyril Chemparathy <cyril@ti.com> writes:

[...]

> Although am3517 (omap) board support code has been updated as needed,
> emac does not work on this platform.

Just to clarify... did EMAC work on AM3517 before this series?

Kevin
