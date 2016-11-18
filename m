From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: Synopsys Ethernet QoS Driver
Date: Fri, 18 Nov 2016 12:31:51 +0000
Message-ID: <dc953ca6-46b4-4b4e-e679-a66227cec21e@synopsys.com>
References: <cbe5f79b-53a4-e116-1e09-bc975a66a8ca@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <CARLOS.PALMINHA@synopsys.com>, <andreas.irestal@axis.com>
To: <davem@davemloft.net>, <jeffrey.t.kirsher@intel.com>,
        <jiri@mellanox.com>, <saeedm@mellanox.com>, <idosch@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay.synopsys.com ([198.182.60.111]:34316 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753149AbcKRMb5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2016 07:31:57 -0500
In-Reply-To: <cbe5f79b-53a4-e116-1e09-bc975a66a8ca@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[The previous e-mail had an error, please consider this one. Thank you.]

Dear all,

My name is Joao Pinto and I work at Synopsys.
I am a kernel developer with special focus in mainline collaboration, both Linux
and Buildroot. I was recently named one of the maintainers of the PCIe
Designware core driver and I was the author of the Designware UFS driver stack.

I am sending you this e-mail because you were the suggested contacts from the
get_maintainers script concerning Ethernet drivers :).

Currently I have the task to work on the mainline Ethernet QoS driver. The work
would consist of the following:

a) Separate the current driver in a Core driver (common ops) + platform glue
driver + pci glue driver
b) Add features that are currently only available internally
c) Add specific phy support using the PHY framework

I would also gladly be available to be its maintainer if you agree with it.

It would be great to have your collaboration in the project if you are available
to review the work in progress.

Thank you and I am looking forward for your feedback!

Joao Pinto
