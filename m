From: "Mike Frysinger" <vapier@gentoo.org>
Subject: Re: [PATCH] SMC91x: delete unused local variable "lp"
Date: Mon, 3 Nov 2008 12:35:17 -0500
Message-ID: <1aad82fa0811030935k37e9e5a6u80df88311aa3c532@mail.gmail.com>
References: <1225288566-18457-1-git-send-email-vapier@gentoo.org>
	 <20081104.014511.108120668.anemo@mba.ocn.ne.jp>
	 <alpine.LFD.2.00.0811031154270.13034@xanadu.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Atsushi Nemoto" <anemo@mba.ocn.ne.jp>, netdev@vger.kernel.org,
	lkml <linux-kernel@vger.kernel.org>
To: "Nicolas Pitre" <nico@cam.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rn-out-0910.google.com ([64.233.170.191]:36086 "EHLO
	rn-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751119AbYKCRfT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2008 12:35:19 -0500
In-Reply-To: <alpine.LFD.2.00.0811031154270.13034@xanadu.home>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

you need to revert both functions.  David Miller has already posted a
patch which adds warning markers instead.
-mike
