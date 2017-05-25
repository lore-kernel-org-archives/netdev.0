From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ip6_tunnel, ip6_gre: fix setting of DSCP on
 encapsulated packets
Date: Thu, 25 May 2017 12:11:17 -0400 (EDT)
Message-ID: <20170525.121117.810915705354733044.davem@davemloft.net>
References: <20170523143616.38116e8f@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, stephen@networkplumber.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: petedaws@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58538 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934424AbdEYQLT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 May 2017 12:11:19 -0400
In-Reply-To: <20170523143616.38116e8f@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Dawson <petedaws@gmail.com>
Date: Tue, 23 May 2017 14:36:16 +1000

> Fixes: https://bugzilla.kernel.org/show_bug.cgi?id=195661

This is not the correct way to use the Fixes: tag.

You should specify the commit that introduced the regression
between 4.9.x and 4.10.x, and that you are fixing here.

The correct format for the commit references is the 12 initial digits
of the SHA1_ID of the commit, followed by a space, followed by the
commit log message header line text enclosed in parentheses and
double quotes with no line breaks whatsoever.

Thank you.
