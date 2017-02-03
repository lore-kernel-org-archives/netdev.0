From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/5] bridge: per vlan dst_metadata support
Date: Fri, 03 Feb 2017 15:21:48 -0500 (EST)
Message-ID: <20170203.152148.1876814711977868978.davem@davemloft.net>
References: <1485932395-58422-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
        nikolay@cumulusnetworks.com, tgraf@suug.ch,
        hannes@stressinduktion.org, jbenc@redhat.com, pshelar@ovn.org,
        dsa@cumulusnetworks.com, hadi@mojatatu.com
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50676 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752035AbdBCUVx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 15:21:53 -0500
In-Reply-To: <1485932395-58422-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>
Date: Tue, 31 Jan 2017 22:59:50 -0800

> lwt and dst_metadata have enabled vxlan l3 deployments
> to use a single vxlan netdev for multiple vnis eliminating the scalability
> problem with using a single vxlan netdev per vni. This series tries to
> do the same for vxlan netdevs in pure l2 bridged networks.
> Use-case/deployment and details are below.

Series applied, thanks Roopa.
