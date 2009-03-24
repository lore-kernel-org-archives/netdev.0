From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] bnx2: Use request_firmware()
Date: Mon, 23 Mar 2009 17:14:36 -0700
Message-ID: <49C825EC.50100@hp.com>
References: <1237501747.4126.10.camel@deadeye.i.decadent.org.uk>	<1237503884.16140.23.camel@HP1>	<20090319232541.GA19262@wavehammer.waldi.eu.org>	<20090320.155030.164080684.davem@davemloft.net>	<1237844879.18617.20.camel@HP1>	<20090323222915.GA29609@wavehammer.waldi.eu.org> <1237850656.18617.34.camel@HP1>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Bastian Blank <waldi@debian.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:43032 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751639AbZCXAOj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2009 20:14:39 -0400
In-Reply-To: <1237850656.18617.34.camel@HP1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Michael Chan wrote:
> May be I'll break up each firmware section into a
> different file and the file name will be updated with each version.
> This will allow different sections to be updated separately and older
> kernels will still have access to the older firmware.

Is that really necessary?  It is enough "fun" finding just the one firmware file 
as it is.

rick jones
