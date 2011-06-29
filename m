From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH RFC] r8169: minimal rtl8111e-vl support
Date: Wed, 29 Jun 2011 21:22:29 +0200
Message-ID: <20110629192229.GA4401@electric-eye.fr.zoreil.com>
References: <20110628214410.GA4163@electric-eye.fr.zoreil.com> <515527CFA16C45B280613F6BDE5C3DF9@realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: hayeswang <hayeswang@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:37611 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757606Ab1F2TgH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2011 15:36:07 -0400
Content-Disposition: inline
In-Reply-To: <515527CFA16C45B280613F6BDE5C3DF9@realtek.com.tw>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hayeswang <hayeswang@realtek.com> :
[...]
> The driver of Realtek includes testing chips which are used internally
> and don't need be supported.
> I plan to start implementing the new chips next week. Maybe you could
> continue after that time if you don't mind.

There may not be much time left for review before net-next closes but
it's fine with me. I'll finish some jumbo fixes in the meantime as they
do not overlap much with new chips support.

-- 
Ueimor
