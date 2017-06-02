From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] qed: Enhance storage APIs
Date: Fri, 02 Jun 2017 10:36:39 -0400 (EDT)
Message-ID: <20170602.103639.467332997454061541.davem@davemloft.net>
References: <20170602055833.21814-1-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
        nilesh.javali@cavium.com, chad.dupuis@cavium.com,
        saurav.kashyap@cavium.com
To: Yuval.Mintz@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43336 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751128AbdFBOgm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Jun 2017 10:36:42 -0400
In-Reply-To: <20170602055833.21814-1-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@cavium.com>
Date: Fri, 2 Jun 2017 08:58:29 +0300

> This series is intended to add additional information and features
> to the API between qed and its storage protocol drivers [qedi, qedf].
> 
> Patch #2 adds some information stored on device such as wwpn & wwnn
> to allow qedf utilize it; #1 fixes an issue with the reading of those
> values [which were unused until now].
> 
> Patch #3 would allow the protocol drivers access to images on persistent
> storage which is a prerequirement for adding boot from SAN support.
> 
> Patch #4 adds infrastrucutre to a future feature for qedi.

Series applied.
