From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 1/9] vxge: Modify
 __vxge_hw_device_is_privilaged() to not assume function-0 as privilaged
 function.
Date: Mon, 05 Oct 2009 02:48:37 -0700 (PDT)
Message-ID: <20091005.024837.62378837.davem@davemloft.net>
References: <Pine.GSO.4.10.10910050503530.2346-100000@guinness>
	<20091005.022017.252887922.davem@davemloft.net>
	<78C9135A3D2ECE4B8162EBDCE82CAD7705C1618F@nekter>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, support@neterion.com
To: Sreenivasa.Honnur@neterion.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52206
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932408AbZJEJsn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2009 05:48:43 -0400
In-Reply-To: <78C9135A3D2ECE4B8162EBDCE82CAD7705C1618F@nekter>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Sreenivasa Honnur" <Sreenivasa.Honnur@neterion.com>
Date: Mon, 5 Oct 2009 05:40:18 -0400

> I could apply these patches with "patch -p1 patch_file" command.

davem@sunset:~/src/GIT/net-next-2.6$ git am --signoff x.mbox
Applying: vxge: Modify __vxge_hw_device_is_privilaged() to not assume function-0 as privilaged function.
error: /drivers/net/vxge/vxge-config.c: does not exist in index
error: patch failed: drivers/net/vxge/vxge-config.c:461
error: drivers/net/vxge/vxge-config.c: patch does not apply
error: /drivers/net/vxge/vxge-version.h: does not exist in index
Patch failed at 0001 vxge: Modify __vxge_hw_device_is_privilaged() to not assume function-0 as privilaged function.

GIT is more strict than patch in many ways (not just in respect
to paths).
