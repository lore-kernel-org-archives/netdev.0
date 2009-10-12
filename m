From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: Occasional crashes with sky2
Date: Mon, 12 Oct 2009 09:11:16 -0700
Message-ID: <20091012091116.24538d3e@nehalam>
References: <4AD1F1F2.4060001@t-online.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Bernd Schmidt <bernds_cb1@t-online.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:36912 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757074AbZJLQME (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2009 12:12:04 -0400
In-Reply-To: <4AD1F1F2.4060001@t-online.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 11 Oct 2009 15:55:46 +0100
Bernd Schmidt <bernds_cb1@t-online.de> wrote:

> For a few months now, I've been seeing occasional kernel panics that
> would happen every few weeks.  I'm not exactly sure when they started,
> but I definitely see them in 2.6.29 and 2.6.30, and never saw them in
> 2.6.25 and earlier.  They happen with 32 bit and 64 bit kernels.
> 
> Today I managed to capture an oops with netconsole; it's attached.  This
> seems to point towards the sky2 driver.
> 

Since you are using tained(nvidia) driver, I really hate to go do indepth
fixing it. And like Mike said 2.6.26 is over a year old by now.

-- 
