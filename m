From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 4/4] iproute2 - Fix up and simplify variables pointing
 to install directories. Define where is the are located the iproute2 config
 files. Get rid of trailing slashes for paths in several file.
Date: Thu, 12 Apr 2012 09:51:13 -0700
Message-ID: <20120412095113.6cb64284@nehalam.linuxnetplumber.net>
References: <20120301164622.GA24306@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Christoph J. Thompson" <cjsthompson@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:48857 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752612Ab2DLQvQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Apr 2012 12:51:16 -0400
In-Reply-To: <20120301164622.GA24306@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 1 Mar 2012 17:46:26 +0100
"Christoph J. Thompson" <cjsthompson@gmail.com> wrote:

> 	modified:   Makefile
> 	modified:   ip/iplink.c
> 	modified:   tc/Makefile
> 	modified:   tc/tc_util.c
> 
> Signed-off-by: Christoph J. Thompson <cjsthompson@gmail.com>

All applied, but you need to format your patch changelog correctly.
Email subject line should be short summary (not a four sentences)
Email body should have the more complete changelog.
Skip the modified: stuff, that is either obvious or put it below
the signature separator --- so that merge program will drop it.
