From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169+NAPI soft lockup
Date: Tue, 9 May 2006 18:43:35 +0200
Message-ID: <20060509164335.GA807@electric-eye.fr.zoreil.com>
References: <4460B8DC.9080105@liv.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:44996 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S1750709AbWEIQrU
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 May 2006 12:47:20 -0400
To: Richard Gregory <R.Gregory@liverpool.ac.uk>
Content-Disposition: inline
In-Reply-To: <4460B8DC.9080105@liv.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Richard Gregory <R.Gregory@liverpool.ac.uk> :
> I'm seeing the crash below using 2.6.16.11 custom based on RedHat FC2. 
> The main culprit being the r8169+NAPI module, although the it821x module 
> (with noraid=1) seems to bring out the bug, maybe because it uses the 
> same interrupt.

(lot of things to digest...)

Is netconsole enabled ?

-- 
Ueimor
