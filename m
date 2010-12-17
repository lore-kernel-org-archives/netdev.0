From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ip: use checksum options of first fragment also for
 subsequent fragments
Date: Fri, 17 Dec 2010 11:58:37 -0800 (PST)
Message-ID: <20101217.115837.39184596.davem@davemloft.net>
References: <1292313093-11973-1-git-send-email-timo.lindfors@iki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: timo.lindfors@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53167
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755568Ab0LQT6I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Dec 2010 14:58:08 -0500
In-Reply-To: <1292313093-11973-1-git-send-email-timo.lindfors@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Timo Juhani Lindfors <timo.lindfors@iki.fi>
Date: Tue, 14 Dec 2010 09:51:33 +0200

> Reference: https://bugzilla.kernel.org/show_bug.cgi?id=24832
> Signed-off-by: Timo Juhani Lindfors <timo.lindfors@iki.fi>

You need to provide a commit log message that actually describes,
in detail, why you are making this change and what the bug is.

Referencing a bugzilla entry is insufficient.
