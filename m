From: "Chas Williams (CONTRACTOR)" <chas@cmf.nrl.navy.mil>
Subject: Re: [PATCH] Fix const assignment/discard warnings in the ATM networking driver
Date: Wed, 09 Jul 2008 16:35:52 -0400
Message-ID: <200807092035.m69KZqOE030495@cmf.nrl.navy.mil>
References: <20080708170452.8406.47939.stgit@warthog.procyon.org.uk>
Reply-To: chas3@users.sourceforge.net
Cc: mitch@sfgoth.com, akpm@linux-foundation.org, netdev@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hedwig.cmf.nrl.navy.mil ([134.207.12.162]:55811 "EHLO
	hedwig.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751074AbYGIUhD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jul 2008 16:37:03 -0400
In-reply-to: <20080708170452.8406.47939.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In message <20080708170452.8406.47939.stgit@warthog.procyon.org.uk>,David Howel
ls writes:
>Fix const assignment/discard warnings in the ATM networking driver.
>
>The lane2_assoc_ind() function needed its arguments changing to match changes
>in the lane2_ops struct (patch 61c33e012964ce358b42d2a1e9cd309af5dab02b).

Acked-by: Chas Williams <chas@cmf.nrl.navy.mil>
