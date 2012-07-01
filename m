From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 2/2] Update bonding driver documentation to include
 IPv6 transmit hashing algorithm.
Date: Sun, 01 Jul 2012 00:34:17 -0700 (PDT)
Message-ID: <20120701.003417.890911456733055306.davem@davemloft.net>
References: <cover.1341125875.git.linux@8192.net>
	<cover.1341125875.git.linux@8192.net>
	<f9bff286392a4778369fa35dac2fafaff3d3a1b8.1341125875.git.linux@8192.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: linux@8192.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46788 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752252Ab2GAHeR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jul 2012 03:34:17 -0400
In-Reply-To: <f9bff286392a4778369fa35dac2fafaff3d3a1b8.1341125875.git.linux@8192.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I think you should combine this into the first patch, there is no
reason to separate these two changes.
