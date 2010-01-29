From: Rusty Russell <rusty@rustcorp.com.au>
Subject: [PATCH 0/2] virtio net improvements
Date: Fri, 29 Jan 2010 23:46:43 +1030
Message-ID: <201001292346.43675.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: virtualization@lists.linux-foundation.org,
	Shirley Ma <mashirle@us.ibm.com>,
	"Michael S. Tsirkin" <mst@redhat.com>
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:39918 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753013Ab0A2NQr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jan 2010 08:16:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

   Nice driver optimization from Shirley, but requires a new virtio hook.
Do you want to take both?  I have nothing else overlapping it.

Cheers,
Rusty.
