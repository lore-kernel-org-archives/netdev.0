From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH] usbnet: Fix a race between usbnet_stop() and the BH
Date: Tue, 08 Sep 2015 09:37:08 +0200
Message-ID: <87fv2ppdjv.fsf@nemi.mork.no>
References: <1441094336.3328.1.camel@suse.com>
	<1441116333-5377-1-git-send-email-eugene.shatokhin@rosalab.ru>
	<55EE8D19.8020703@rosalab.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Oliver Neukum <oneukum@suse.de>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eugene Shatokhin <eugene.shatokhin@rosalab.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:59612 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753238AbbIHHh1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Sep 2015 03:37:27 -0400
In-Reply-To: <55EE8D19.8020703@rosalab.ru> (Eugene Shatokhin's message of
	"Tue, 8 Sep 2015 10:24:09 +0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eugene Shatokhin <eugene.shatokhin@rosalab.ru> writes:

> I resent the patch to make it separate. What is the status of this no=
w?

One of the many nice features of patchwork is that you don't need to as=
k
those questions :)

See http://patchwork.ozlabs.org/patch/512856/

I really don't think it's appropriate for me to ack this, but I can add
my

Reviewed-by: Bj=C3=B8rn Mork <bjorn@mork.no>

if that helps.


Bj=C3=B8rn
