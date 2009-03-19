From: Bastian Blank <waldi@debian.org>
Subject: Re: [PATCH] bnx2: Use request_firmware()
Date: Fri, 20 Mar 2009 00:25:41 +0100
Message-ID: <20090319232541.GA19262@wavehammer.waldi.eu.org>
References: <1237501747.4126.10.camel@deadeye.i.decadent.org.uk> <1237503884.16140.23.camel@HP1>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Ben Hutchings <ben@decadent.org.uk>,
	David Miller <davem@davemloft.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wavehammer.waldi.eu.org ([82.139.201.20]:43526 "EHLO
	wavehammer.waldi.eu.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753261AbZCSXb6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2009 19:31:58 -0400
Content-Disposition: inline
In-Reply-To: <1237503884.16140.23.camel@HP1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 19, 2009 at 04:04:44PM -0700, Michael Chan wrote:
> Thanks Ben and Bastian.  I will review this and test it out.  I think I
> will add some logic to check firmware versions to guarantee some level
> of compatibility.

The firmware version is coded into the filenames.

Bastian

-- 
Violence in reality is quite different from theory.
		-- Spock, "The Cloud Minders", stardate 5818.4
