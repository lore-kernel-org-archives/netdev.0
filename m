From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 3.9.5+:  Crash in tcp_input.c:4810.
Date: Mon, 08 Jul 2013 11:21:42 -0700
Message-ID: <1373307702.4979.116.camel@edumazet-glaptop>
References: <51BF50B3.1080403@candelatech.com>
	    <1371493059.3252.200.camel@edumazet-glaptop>
	    <51D1C620.8030007@candelatech.com>
	   <1372813467.4979.46.camel@edumazet-glaptop>
	   <51D398C0.5060802@candelatech.com>
	  <1372826512.4979.49.camel@edumazet-glaptop>
	  <51D3AD66.8030506@candelatech.com>
	 <1372827749.4979.52.camel@edumazet-glaptop>
	 <51DAF5A7.60505@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f173.google.com ([209.85.214.173]:40238 "EHLO
	mail-ob0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751392Ab3GHSVs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jul 2013 14:21:48 -0400
Received: by mail-ob0-f173.google.com with SMTP id wc20so5865523obb.18
        for <netdev@vger.kernel.org>; Mon, 08 Jul 2013 11:21:48 -0700 (PDT)
In-Reply-To: <51DAF5A7.60505@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-07-08 at 10:23 -0700, Ben Greear wrote:

> We ran a 5+ day test using un-modified 3.10 kernel and did not trigger
> the bug.

Using wired ethernet only, or any kind of adapters, including ath9k ?

> So, I'm guessing the problem is either fixed upstream or is exacerbated
> or caused by our local patches.  Sometime soon we'll start porting local
> patches to newer kernels...we'll see what happens then.

Thanks
