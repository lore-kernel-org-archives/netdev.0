From: "Beschorner Daniel" <Daniel.Beschorner@facton.com>
Subject: Re: oops with ipcomp
Date: Mon, 11 Feb 2008 16:03:46 +0100
Message-ID: <3C59DB883F7B0B4D8096010D45ACCD134F20DA@exch.facton.local>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Herbert Xu" <herbert@gondor.apana.org.au>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alpha.facton.com ([83.236.152.122]:60560 "EHLO alpha.facton.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753522AbYBKPDx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Feb 2008 10:03:53 -0500
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Does every packet from A trigger the crash?

In my last test the crash was triggered after 300MB of http output (on
the fifth run of a script downloading the same 60MB of data).
