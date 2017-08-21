From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: IPsec workshop at netdevconf
Date: Mon, 21 Aug 2017 09:10:49 +0200
Message-ID: <20170821071049.GE31224@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: "Skidmore, Donald C" <donald.c.skidmore@intel.com>,
        Boris Pismenny <borisp@mellanox.com>,
        Florian Westphal <fw@strlen.de>,
        Sowmini Varadhan <sowmini.varadhan@oracle.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:37434 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751010AbdHUHKw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 21 Aug 2017 03:10:52 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

we plan for an IPsec workshop at the next netdev conference in November.
Is there anybody interested to present something or is there anybody who
want to discuss something?

So far we have the following tentative topics:

Donald Skidmore:

Presentation: The intel implementation of the IPsec offload support.
Discussion: Virtualization with IPsec offload; IPsec offload with OVS

Boris Pismenny:

Presentation: Describe trailer removal; Describe ESN; show performance
numbers.

Discussion: Full device terminated IPsec offload; software fallback
problems common to TLS and IPsec; auth failure using decrypted packet
vs. plaintext packet

Steffen Klassert:

Presentation: The IPsec status update.

Discussion: Redesigning the IPsec VTI interfaces.
