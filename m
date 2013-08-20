From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] r8169,sis190: remove unnecessary length check
Date: Tue, 20 Aug 2013 22:45:58 +0200
Message-ID: <20130820204558.GA26241@electric-eye.fr.zoreil.com>
References: <1376694473-8517-1-git-send-email-lekensteyn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org
To: Peter Wu <lekensteyn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:37610 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751082Ab3HTUqF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Aug 2013 16:46:05 -0400
Content-Disposition: inline
In-Reply-To: <1376694473-8517-1-git-send-email-lekensteyn@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Peter Wu <lekensteyn@gmail.com> :
[...]
> This was observed by Ben[1] while reviewing my other r8169 register dump
> patch. I have combined the r8169 and sis190 patches since they were
> trivial and both maintained by Francois. Let me know if you prefer to
> split this trivial patch up.

(missed this one)

I'm fine with it.

-- 
Ueimor
