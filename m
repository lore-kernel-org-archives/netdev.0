From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH] bnx2x: remove the 'poll' module option
Date: Tue, 14 Feb 2012 21:14:02 +0200
Message-ID: <1329246842.30697.0.camel@lb-tlvb-eilong.il.broadcom.com>
References: <1329246346-9993-1-git-send-email-mschmidt@redhat.com>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gideonn@broadcom.com
To: "Michal Schmidt" <mschmidt@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1197 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759456Ab2BNTOP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Feb 2012 14:14:15 -0500
In-Reply-To: <1329246346-9993-1-git-send-email-mschmidt@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-02-14 at 20:05 +0100, Michal Schmidt wrote:
> 'poll' was a debugging option, but turning it on these days leads to
> kernel panic. Remove it.
> 
> Signed-off-by: Michal Schmidt <mschmidt@redhat.com>

Michal - thanks for taking care of it. Your help is truly appreciated.

Acked-by Eilon Greenstein <eilong@broadcom.com>
