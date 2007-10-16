From: Karsten Wiese <fzu@wemgehoertderstaat.de>
Subject: Re: [PATCH] Disable polling in rtl8169_suspend() to prevent race with rtl8169_interrupt()
Date: Wed, 17 Oct 2007 00:21:38 +0200
Message-ID: <200710170021.38743.fzu@wemgehoertderstaat.de>
References: <200710161846.52509.fzu@wemgehoertderstaat.de> <20071016210412.GB8049@electric-eye.fr.zoreil.com> <200710170010.36329.fzu@wemgehoertderstaat.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout2.freenet.de ([195.4.92.92]:49166 "EHLO mout2.freenet.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966764AbXJPWVl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Oct 2007 18:21:41 -0400
In-Reply-To: <200710170010.36329.fzu@wemgehoertderstaat.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Mittwoch, 17. Oktober 2007 schrieb Karsten Wiese:

to nonsense comments, please ignore:
> this          ^..........^ looked funny to me
and
> back to normal ^.........^
