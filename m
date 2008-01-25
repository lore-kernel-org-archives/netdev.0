From: "Beschorner Daniel" <Daniel.Beschorner@facton.com>
Subject: ipcomp regression in 2.6.24?
Date: Fri, 25 Jan 2008 16:57:29 +0100
Message-ID: <3C59DB883F7B0B4D8096010D45ACCD134F207F@exch.facton.local>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alpha.facton.com ([83.236.152.122]:58479 "EHLO alpha.facton.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755143AbYAYQFH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jan 2008 11:05:07 -0500
Received: from exch.facton.local (exch [192.168.200.5])
	by alpha.facton.com (8.13.8/8.13.8/FACTON) with ESMTP id m0PFvT46005391
	for <netdev@vger.kernel.org>; Fri, 25 Jan 2008 16:57:29 +0100
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With 2.6.24 IPSEC/ESP tunnels to older kernels establish fine, data
flows in both directions, but no data comes out of the tunnel.
Needed to disable ipcomp.

Daniel
