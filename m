From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 2/2] r8169: allow true forced mode setting
Date: Sun, 17 May 2009 12:34:50 +0200
Message-ID: <20090517103450.GA25833@electric-eye.fr.zoreil.com>
References: <20090514214605.GB6374@electric-eye.fr.zoreil.com> <200905161450.38281.jdelvare@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Vincent Steenhoute <vsteenhoute@novell.com>,
	Martin Michlmayr <tbm@cyrius.com>,
	Xose Vazquez Perez <xose.vazquez@gmail.com>,
	Ivan Vecera <ivecera@redhat.com>,
	Edward Hsu <edward_hsu@realtek.com.tw>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org
To: Jean Delvare <jdelvare@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:34242 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750804AbZEQKew (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 May 2009 06:34:52 -0400
Content-Disposition: inline
In-Reply-To: <200905161450.38281.jdelvare@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jean Delvare <jdelvare@suse.de> :
[...]
> If I read the code correctly, Realtek's driver (v6.010.00) only
> applies the quirk for RTL8169S and RTL8110S chips (what I have) and
> not the original RTL8169. Your code applies the quirk to all 3
> chips. Is this on purpose? Or am I missing something?

It is on purpose but it is not necessarily conservative enough.

I'll resend it.

Thanks.

-- 
Ueimor
