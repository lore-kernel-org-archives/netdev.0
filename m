From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] alx: add msi-x support
Date: Fri, 09 Sep 2016 20:51:35 -0700 (PDT)
Message-ID: <20160909.205135.67795328551477153.davem@davemloft.net>
References: <cover.1473404399.git.tobias.regnery@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jcliburn@gmail.com, chris.snook@gmail.com,
        feng.tang@intel.com, jarod@redhat.com
To: tobias.regnery@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36490 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750882AbcIJDvm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Sep 2016 23:51:42 -0400
In-Reply-To: <cover.1473404399.git.tobias.regnery@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Regnery <tobias.regnery@gmail.com>
Date: Fri,  9 Sep 2016 12:19:51 +0200

> This patchset adds msi-x support to the alx driver. It is a preparatory
> series for multi queue support, which I am currently working on. As there
> is no advantage over msi interrupts without multi queue support, msi-x
> interrupts are disabled by default. In order to test for regressions, a
> new module parameter is added to enable msi-x interrupts.
> 
> Based on information of the downstream driver at github.com/qca/alx

Series applied, thanks.
