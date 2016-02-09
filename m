From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 2/2] tipc: add peer remove functionality
Date: Tue, 9 Feb 2016 11:00:54 -0800
Message-ID: <20160209110054.5c5a0a1a@xeon-e3>
References: <1451987860-17696-1-git-send-email-richard.alpe@ericsson.com>
	<1451987860-17696-2-git-send-email-richard.alpe@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <tipc-discussion@lists.sourceforge.net>
To: Richard Alpe <richard.alpe@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:34614 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751874AbcBITAo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Feb 2016 14:00:44 -0500
Received: by mail-pa0-f48.google.com with SMTP id ez2so3096745pad.1
        for <netdev@vger.kernel.org>; Tue, 09 Feb 2016 11:00:43 -0800 (PST)
In-Reply-To: <1451987860-17696-2-git-send-email-richard.alpe@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I ended up reverting this patch from iproute2 because the code in kernel
was not accepted upstream.

After it is upstream in kernel please resubmit
