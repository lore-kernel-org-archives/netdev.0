From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute PATCH 2/2] bridge.8: minor formatting cleanup
Date: Mon, 23 Nov 2015 15:57:31 -0800
Message-ID: <20151123155731.3e882df2@xeon-e3>
References: <1447847203-7462-1-git-send-email-phil@nwl.cc>
	<1447847203-7462-3-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:35905 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751804AbbKWX5V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2015 18:57:21 -0500
Received: by pacdm15 with SMTP id dm15so486474pac.3
        for <netdev@vger.kernel.org>; Mon, 23 Nov 2015 15:57:20 -0800 (PST)
In-Reply-To: <1447847203-7462-3-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 18 Nov 2015 12:46:43 +0100
Phil Sutter <phil@nwl.cc> wrote:

> - Replace commas at end of subsection with dots.
> - Remove whitespace at EOL.
> - Replace double whitespace by single one.
> 
> Signed-off-by: Phil Sutter <phil@nwl.cc>

Could you redo this patch. It crossed over with my changes
to scrub all the trailing whitespace on man8 pages.
