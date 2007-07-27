From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH 4/4] l2cap: don't mangle cmd.len
Date: Fri, 27 Jul 2007 16:41:26 +0200
Message-ID: <1185547286.13228.18.camel@violet>
References: <E1IEPNw-0005TA-89@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Al Viro <viro@ftp.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from coyote.holtmann.net ([217.160.111.169]:35550 "EHLO
	mail.holtmann.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934502AbXG0OjZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jul 2007 10:39:25 -0400
In-Reply-To: <E1IEPNw-0005TA-89@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Al,

> Since nobody uses it after we convert it to host-endian,
> no need to do that at all.  At that point l2cap is endian-clean.
> 
> Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>

Signed-off-by: Marcel Holtmann <marcel@holtmann.org>

Regards

Marcel


