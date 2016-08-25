From: Rick Jones <rick.jones2@hpe.com>
Subject: Re: [RFC PATCH] net: Require socket to allow XPS to set queue mapping
Date: Thu, 25 Aug 2016 14:28:04 -0700
Message-ID: <3a1d23f2-d2c6-8d28-96cc-1b25b61b948c@hpe.com>
References: <147215300812.3936.8031402062962283044.stgit@ahduyck-desk.amr.corp.intel.com>
 <1472154564.14381.160.camel@edumazet-glaptop3.roam.corp.google.com>
 <3fd7a334-c660-6e31-1466-27b08a2c983f@hpe.com>
 <1472159297.14381.162.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
        netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g2t1383g.austin.hpe.com ([15.233.16.89]:17772 "EHLO
        g2t1383g.austin.hpe.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758595AbcHYVav (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2016 17:30:51 -0400
Received: from g4t3427.houston.hpe.com (g4t3427.houston.hpe.com [15.241.140.73])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by g2t1383g.austin.hpe.com (Postfix) with ESMTPS id 7BDF51D11
        for <netdev@vger.kernel.org>; Thu, 25 Aug 2016 21:29:48 +0000 (UTC)
In-Reply-To: <1472159297.14381.162.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/25/2016 02:08 PM, Eric Dumazet wrote:
> When XPS was submitted, it was _not_ enabled by default and 'magic'
>
> Some NIC vendors decided it was a good thing, you should complain to
> them ;)

I kindasorta am with the emails I've been sending to netdev :)  And also 
hopefully precluding others going down that path.

happy benchmarking,

rick
