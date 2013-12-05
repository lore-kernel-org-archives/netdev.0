From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH RFC 0/9] vti4: prepare namespace and interfamily
 support.
Date: Thu, 5 Dec 2013 09:27:04 -0800
Message-ID: <20131205092704.2b2c4cb4@nehalam.linuxnetplumber.net>
References: <20131205120028.GW31491@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Christophe Gouault <christophe.gouault@6wind.com>,
	Saurabh Mohan <saurabh.mohan@vyatta.com>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:57746 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756897Ab3LER1H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 12:27:07 -0500
Received: by mail-pd0-f174.google.com with SMTP id y13so25177951pdi.33
        for <netdev@vger.kernel.org>; Thu, 05 Dec 2013 09:27:07 -0800 (PST)
In-Reply-To: <20131205120028.GW31491@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 5 Dec 2013 13:00:28 +0100
Steffen Klassert <steffen.klassert@secunet.com> wrote:

> This patchset prepares vti4 for proper namespace and interfamily support.
> It is based on the net tree because net-next is still too far behind the
> mainline.

Then ask David to merge net -> net-next. That is the standard method
to submit new feature patches that overlap.
