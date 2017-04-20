From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 04/14] i40e: dump VF information in debugfs
Date: Thu, 20 Apr 2017 12:58:41 -0400 (EDT)
Message-ID: <20170420.125841.799913763607507081.davem@davemloft.net>
References: <BL2PR07MB2306DEC60F085B88BA230C3A8D1B0@BL2PR07MB2306.namprd07.prod.outlook.com>
        <20170420.115153.1510206006505486594.davem@davemloft.net>
        <BL2PR07MB23063D7F1341E629E9345F578D1B0@BL2PR07MB2306.namprd07.prod.outlook.com>
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
Received: from shards.monkeyblade.net ([184.105.139.130]:45200 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S971374AbdDTQ6q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 12:58:46 -0400
In-Reply-To: <BL2PR07MB23063D7F1341E629E9345F578D1B0@BL2PR07MB2306.namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Date: Thu, 20 Apr 2017 16:24:51 +0000

> the HW pipeline itself can't be abstracted in this case.

I've heard that argument before, and I'm glad Jiri didn't drink the
koolaide and instead wrote dpipe.
