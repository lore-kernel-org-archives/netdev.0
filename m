From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] inet: fix sysctl_local_ports init when
 namespaces are used
Date: Wed, 07 May 2014 16:48:31 -0400 (EDT)
Message-ID: <20140507.164831.788753799040064052.davem@davemloft.net>
References: <20140505222916.GA2299@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stefan@konink.de, dborkman@redhat.com,
	stephen@networkplumber.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51754 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751000AbaEGUsd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2014 16:48:33 -0400
In-Reply-To: <20140505222916.GA2299@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Tue, 6 May 2014 00:29:16 +0200

> Bug: https://bugzilla.kernel.org/show_bug.cgi?id=75221

Like Cong, I would have wanted a detailed commit log message explaining
the exact bug and why you fixed it the way you did.

It seems like Cong's patch deals with it in a different way but needs
a more formal submission so I'll mark all of this superceded.
