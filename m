From: David Brownell <david-b@pacbell.net>
Subject: Re: [PATCH 0/2] qcusbnet: Cleanups
Date: Fri, 1 Oct 2010 11:29:43 -0700 (PDT)
Message-ID: <248003.88729.qm@web180309.mail.gq1.yahoo.com>
References: <20101001144231.GC8632@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	dbrownell@users.sourceforge.net, mjg59@srcf.ucam.org,
	jglasgow@google.com, msb@google.com, olofj@google.com
To: Joe Perches <joe@perches.com>, Elly Jones <ellyjones@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from n79.bullet.mail.sp1.yahoo.com ([98.136.44.39]:38868 "HELO
	n79.bullet.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753915Ab0JAS3q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Oct 2010 14:29:46 -0400
In-Reply-To: <20101001144231.GC8632@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've not noticed this driver before .. can its
name be changed soon?  As it is, it's easily
confused with "usbnet", the driver framework.

Please give it a name that just reflects the
hardware it drives, eliminating that confusion.


