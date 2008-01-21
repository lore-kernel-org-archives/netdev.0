From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 1/3 v2][NET] gen_estimator: faster gen_kill_estimator
Date: Mon, 21 Jan 2008 23:41:27 +0100
Message-ID: <20080121224127.GA4386@ami.dom.local>
References: <20080120234659.GA2691@ami.dom.local> <20080121223137.GB2758@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Badalian Vyacheslav <slavon@bigtelecom.ru>,
	Patrick McHardy <kaber@trash.net>, jamal <hadi@cyberus.ca>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.191]:16904 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751775AbYAUWjB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2008 17:39:01 -0500
Received: by nf-out-0910.google.com with SMTP id g13so359129nfb.21
        for <netdev@vger.kernel.org>; Mon, 21 Jan 2008 14:39:00 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080121223137.GB2758@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 21, 2008 at 11:31:37PM +0100, Jarek Poplawski wrote:
> 
> So, let's try something easy first: #ifdef __KERNEL__. (I know there
...

SORRY!!! Of course this is still wrong, I withdraw this patch.

Jarek P.
