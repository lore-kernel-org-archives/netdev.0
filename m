From: Florian Weimer <fw@deneb.enyo.de>
Subject: Re: [PATCH] Implement IP_EVIL socket option (RFC 3514)
Date: Wed, 04 Apr 2012 21:17:00 +0200
Message-ID: <87r4w3nw7n.fsf@mid.deneb.enyo.de>
References: <1333284791-5363-1-git-send-email-martin@lucina.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Martin Lucina <martin@lucina.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1333284791-5363-1-git-send-email-martin@lucina.net> (Martin
	Lucina's message of "Sun, 1 Apr 2012 14:53:11 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Martin Lucina:

> This patch implements the IP_EVIL socket option, allowing user-space
> applications to set the Security Flag in the IPv4 Header, aka "evil" bit,
> as defined in RFC 3514.

I need this to fix a security issue.  Could this be merged for real,
please?
