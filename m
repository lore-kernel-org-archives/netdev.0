From: Tobias Klauser <tklauser@distanz.ch>
Subject: Re: [PATCH] greth: Use return value of register_netdev
Date: Tue, 17 Aug 2010 18:14:00 +0200
Message-ID: <20100817161400.GE15670@distanz.ch>
References: <1282061527-19429-1-git-send-email-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kernel-janitors@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from symlink.to.noone.org ([85.10.207.172]:47671 "EHLO sym.noone.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757190Ab0HQQTt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Aug 2010 12:19:49 -0400
Content-Disposition: inline
In-Reply-To: <1282061527-19429-1-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2010-08-17 at 18:12:07 +0200, Tobias Klauser <tklauser@distanz.ch> wrote:
> Use the return value provided by register_netdev on error instead of
> hard setting it to -ENOMEM.

Sorry for the duplicate, please disregard this one.
