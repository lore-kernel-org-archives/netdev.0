From: "Beschorner Daniel" <Daniel.Beschorner@facton.com>
Subject: ipcomp regression in 2.6.24
Date: Mon, 28 Jan 2008 20:00:09 +0100
Message-ID: <3C59DB883F7B0B4D8096010D45ACCD134F2086@exch.facton.local>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alpha.facton.com ([83.236.152.122]:43912 "EHLO alpha.facton.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752459AbYA1TAN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jan 2008 14:00:13 -0500
Received: from exch.facton.local (exch [192.168.200.5])
	by alpha.facton.com (8.13.8/8.13.8/FACTON) with ESMTP id m0SJ09Ij012361
	for <netdev@vger.kernel.org>; Mon, 28 Jan 2008 20:00:09 +0100
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Has someone an idea which patch could have damaged ipcomp?

Daniel

> With 2.6.24 IPSEC/ESP tunnels to older kernels establish fine, data
> flows in both directions, but no data comes out of the tunnel.
> Needed to disable ipcomp.
