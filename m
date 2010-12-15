From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [OOPS]e1000e .ko 1.0.2-k2
Date: Wed, 15 Dec 2010 13:52:34 +0000
Message-ID: <1292421154.3136.642.camel@localhost>
References: <1292402583.2484.25.camel@cephhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: cpwu@tnsoft.com.cn
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:23101 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752650Ab0LONwh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Dec 2010 08:52:37 -0500
In-Reply-To: <1292402583.2484.25.camel@cephhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-12-15 at 16:43 +0800, Jeff Wu wrote:
> Hi ,
> 
> iozone test for our distributed file system ,
> we detect a oops(see below ,logs).

This is not an oops.

[...]
> [181174.967056] SLUB: Unable to allocate memory on node -1 (gfp=0x20)
[...]

Read that line again.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

