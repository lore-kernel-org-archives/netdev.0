From: Enrico Mioso <mrkiko.rs@gmail.com>
Subject: Re: [PATCH RFC] cdc_ncm.c: make rx and tx functions exportable
Date: Tue, 2 Jul 2013 14:05:01 +0200 (CEST)
Message-ID: <alpine.LNX.2.02.1307021404280.11365@eeeadesso>
References: <alpine.LNX.2.02.1307021241380.8884@eeeadesso> <87wqp9xja5.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Enrico Mioso <mrkiko.rs@gmail.com>, netdev@vger.kernel.org
To: =?ISO-8859-15?Q?Bj=F8rn_Mork?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:43133 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750769Ab3GBMEm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jul 2013 08:04:42 -0400
Received: by mail-wi0-f179.google.com with SMTP id hj3so4134142wib.0
        for <netdev@vger.kernel.org>; Tue, 02 Jul 2013 05:04:41 -0700 (PDT)
In-Reply-To: <87wqp9xja5.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thank you very much Bjorn! I will do so!



On Tue, 2 Jul 2013, Bj?rn Mork wrote:

==Date: Tue, 02 Jul 2013 14:01:38 +0200
==From: Bj?rn Mork <bjorn@mork.no>
==To: Enrico Mioso <mrkiko.rs@gmail.com>
==Cc: netdev@vger.kernel.org
==Subject: Re: [PATCH RFC] cdc_ncm.c: make rx and tx functions exportable
==
==Enrico Mioso <mrkiko.rs@gmail.com> writes:
==
==> This patch factors out rx and tx fixup functions from cdc_ncm.c driver.
==> This will be useful once implementing a specific driverto handle
==> huawei specific ncm implementation.
==
==It is good to keep this change as a separate patch, but it needs to be
==sumbitted as part of a series including the code using it.  Most
==reviewers are unable to understand plain text - they can only read code
==:)
==
==So it is better to keep this for yourself until you have a working
==driver using the exported functions, and then post it all as a patch
==series.  That's the best way to show how you intend to use stuff like
==this.
==
==And I suggest you CC Alexey Orishko for all changes to the cdc_ncm
==driver.  The ST-Ericsson address in the driver is probably bouncing now,
==but you can reach him at "Alexey Orishko <alexey.orishko@gmail.com>"
==
==
==
==Bj?rn
==
