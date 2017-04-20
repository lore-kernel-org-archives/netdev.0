From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 04/14] i40e: dump VF information in debugfs
Date: Thu, 20 Apr 2017 16:35:48 -0400 (EDT)
Message-ID: <20170420.163548.662307112452546016.davem@davemloft.net>
References: <BL2PR07MB23063D7F1341E629E9345F578D1B0@BL2PR07MB2306.namprd07.prod.outlook.com>
        <20170420.125841.799913763607507081.davem@davemloft.net>
        <BL2PR07MB23064B547F325DD002E513FC8D1B0@BL2PR07MB2306.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, gerlitz.or@gmail.com,
        jeffrey.t.kirsher@intel.com, mitch.a.williams@intel.com,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Chad.Dupuis@cavium.com,
        Manish.Rangankar@cavium.com
To: Yuval.Mintz@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49222 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1033009AbdDTUfw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 16:35:52 -0400
In-Reply-To: <BL2PR07MB23064B547F325DD002E513FC8D1B0@BL2PR07MB2306.namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Date: Thu, 20 Apr 2017 20:12:59 +0000

> I surely wouldn't want to write a million lines of code just to
> provide such a detailed abstraction.

So now the argument has gone from "it's not possible" to "it's going
to be a HUGE amount of code."

I wonder what the next argument will be when I shoot this one down.

If you simply don't want to do the hard work necessary to implement
this properly, which is fine, just say so.
