From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 2/3] net: Guaranetee the proper ordering of the loopback device.
Date: Fri, 07 Nov 2008 23:13:30 -0800
Message-ID: <m1fxm2r8px.fsf@frodo.ebiederm.org>
References: <m1y6zx3gcs.fsf_-_@frodo.ebiederm.org>
	<20081105.160047.174722021.davem@davemloft.net>
	<m14p2l0zyu.fsf@frodo.ebiederm.org>
	<20081107.225352.193700609.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dlezcano@fr.ibm.com, containers@lists.osdl.org, den@openvz.org,
	xemul@openvz.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:47770 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752278AbYKHHPW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Nov 2008 02:15:22 -0500
In-Reply-To: <20081107.225352.193700609.davem@davemloft.net> (David Miller's
	message of "Fri, 07 Nov 2008 22:53:52 -0800 (PST)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> I'm putting a revert changeset in there, then your two new patches on
> top.
>
> I'm not screwing up my GIT tree for everyone who pulls from me just
> because you can't be bothered to test the actual changes you send me.

Understood.  When I sent the email it looked like it might not have landed
in your git tree yet.  I badly messed up on that one and I apologize.

Eric

