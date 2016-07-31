From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute PATCH 1/2] include: Add linux/sctp.h
Date: Sun, 31 Jul 2016 14:19:36 -0700
Message-ID: <20160731141936.0397f7d5@xeon-e3>
References: <1469831240-30322-1-git-send-email-phil@nwl.cc>
	<21dc09f1e50d4b7195c19796633b2035@HQ1WP-EXMB11.corp.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemming@Brocade.com>,
	Xin Long <lucien.xin@gmail.com>, netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:34799 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751354AbcGaVZL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Jul 2016 17:25:11 -0400
Received: by mail-pa0-f43.google.com with SMTP id fi15so46172447pac.1
        for <netdev@vger.kernel.org>; Sun, 31 Jul 2016 14:25:01 -0700 (PDT)
In-Reply-To: <21dc09f1e50d4b7195c19796633b2035@HQ1WP-EXMB11.corp.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 29 Jul 2016 22:27:19 +0000
Phil Sutter <phil@nwl.cc> wrote:

> This header does not exist in this form upstream yet, as it contains
> struct sctp_info which is required for SCTP support in 'ss' and hasn't
> been exported yet.
> 
> Signed-off-by: Phil Sutter <phil@nwl.cc>

Holding off on this until header is correctly exported from kernel.
