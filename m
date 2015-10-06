From: David Miller <davem@davemloft.net>
Subject: Re: [net-next:master 647/682] fib_semantics.c:undefined reference
 to `__divdi3'
Date: Mon, 05 Oct 2015 23:42:26 -0700 (PDT)
Message-ID: <20151005.234226.1882984429611604223.davem@davemloft.net>
References: <201510051816.pL2fiACx%fengguang.wu@intel.com>
	<20151005.042638.1280563834697071426.davem@davemloft.net>
	<20151005233158.2c09adce@tyr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: fengguang.wu@intel.com, kbuild-all@01.org, netdev@vger.kernel.org
To: pch@ordbogen.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44754 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750934AbbJFG0p convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2015 02:26:45 -0400
In-Reply-To: <20151005233158.2c09adce@tyr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Peter N=F8rlund <pch@ordbogen.com>
Date: Mon, 5 Oct 2015 23:31:58 +0200

> What is the proper way to supply fixes for this kind of errors? Shoul=
d
> I submit the original patches again with the bug fixed, or should I
> submit a patch fixing this particular problem? I imagine bisecting
> becomes annoying when a particular commit doesn't compile.

Once a patch is in my tree, it is part of the permanent record and
cannot be removed.  Therefore you must send me a fix for this
problem.
