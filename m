From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 3/14] nes: connection manager routines
Date: 08 Aug 2007 14:41:01 +0200
Message-ID: <p73d4xyryg2.fsf@bingen.suse.de>
References: <200708080050.l780oGxo004694@neteffect.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rdreier@cisco.com, ewg@lists.openfabrics.org,
	netdev@vger.kernel.org
To: ggrundstrom@neteffect.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:56640 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751470AbXHHLqm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Aug 2007 07:46:42 -0400
In-Reply-To: <200708080050.l780oGxo004694@neteffect.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ggrundstrom@neteffect.com writes:

> NetEffect connection manager routines.

This seems more like a new TCP stack. I don't think such code
is appropiate, since Linux already has one.

-Andi
