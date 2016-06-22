From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 regression: UDP packets dropped intermittantly
Date: Thu, 23 Jun 2016 01:22:50 +0200
Message-ID: <20160622232250.GA26424@electric-eye.fr.zoreil.com>
References: <20151130064255.GL5537@marvin.atrad.com.au>
 <20151201235852.GA16429@electric-eye.fr.zoreil.com>
 <20160208023318.GJ9174@marvin.atrad.com.au>
 <20160407024417.GE17921@marvin.atrad.com.au>
 <20160517065231.GO30050@marvin.atrad.com.au>
 <20160518065137.GJ27564@marvin.atrad.com.au>
 <20160601003123.GE3384@marvin.atrad.com.au>
 <20160621032133.GC19735@marvin.atrad.com.au>
 <20160621230957.GA19674@electric-eye.fr.zoreil.com>
 <20160621235938.GB13364@marvin.atrad.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jonathan Woithe <jwoithe@atrad.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:46596 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751704AbcFVXXB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 19:23:01 -0400
Content-Disposition: inline
In-Reply-To: <20160621235938.GB13364@marvin.atrad.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jonathan Woithe <jwoithe@atrad.com.au> :
[...]
> to mainline (in which case I'll keep watching out for it)?  Or is the
> out-of-tree workaround mentioned above considered to be the long term
> fix for those who encounter the problem?

It's a workaround. Nothing less, nothing more.

IIRC the ga311 irq signaling was a bit special. I almost surely broke
it at some point.

-- 
Ueimor
