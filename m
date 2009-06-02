From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net_cls: fix unconfigured struct tcf_proto keeps
 chaining and avoid kernel panic when we use cls_cgroup
Date: Tue, 02 Jun 2009 02:17:50 -0700 (PDT)
Message-ID: <20090602.021750.168396293.davem@davemloft.net>
References: <20090602181148.e01f0417.usui@mxm.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, containers@lists.linux-foundation.org,
	jarkao2@gmail.com, hadi@cyberus.ca
To: usui@mxm.nes.nec.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47058
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752941AbZFBJRu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2009 05:17:50 -0400
In-Reply-To: <20090602181148.e01f0417.usui@mxm.nes.nec.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Minoru Usui <usui@mxm.nes.nec.co.jp>
Date: Tue, 2 Jun 2009 18:11:48 +0900

> net_cls: fix unconfigured struct tcf_proto keeps chaining and avoid kernel panic when we use cls_cgroup

Patch applied, thank you.
