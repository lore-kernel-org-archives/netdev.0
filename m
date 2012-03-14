From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: linux-3.0.18+r8169+ipv4/tcp forwarding = tso/gso weirdness and performance degration
Date: Wed, 14 Mar 2012 22:16:07 +0100
Message-ID: <20120314211607.GA29398@electric-eye.fr.zoreil.com>
References: <20120314190156.622c8cd5@vostro>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Timo Teras <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:50425 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932388Ab2CNVRg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Mar 2012 17:17:36 -0400
Content-Disposition: inline
In-Reply-To: <20120314190156.622c8cd5@vostro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Timo Teras <timo.teras@iki.fi> :
> I have a router box running linux-3.0.18 (with grsec patches).
[...]
> Any pointers how to next debug/fix/workaround this issue?

No difference without grsec (test version) patch ?

-- 
Ueimor
