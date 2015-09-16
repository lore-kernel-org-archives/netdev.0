From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: FW: [RFC net-next 01/10] qed: Add module with basic common support
Date: Wed, 16 Sep 2015 05:53:49 +0000
Message-ID: <B5657A6538887040AD3A81F1008BEC63E27EBC@avmb3.qlogic.org>
References: <1441893261-6222-1-git-send-email-Yuval.Mintz@qlogic.com>
	<1441893261-6222-2-git-send-email-Yuval.Mintz@qlogic.com>,<20150910.101057.1870095895052608803.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Ariel Elior <Ariel.Elior@qlogic.com>
To: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:49595 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750989AbbIPFxx convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Sep 2015 01:53:53 -0400
In-Reply-To: <20150910.101057.1870095895052608803.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Yuval Mintz <Yuval.Mintz@qlogic.com>
> Date: Thu, 10 Sep 2015 16:54:12 +0300

> >  Documentation/networking/LICENSE.qlogic            |  288 ++

> I do not want to get into the habit of having to add copy after copy
> of the GPL v2 to the source tree, so this is rather inappropriate.

> Everything said in that file is explicitly covered by the top-level
> COPYING file.

You're right; We'll remove this and add some comment reference
to COPYING instead in v2.

On a related but different topic,  I've noticed a lack of commentary
for this series; Don't know if it's due to lack of time, interest, or
something else.
[I know we write perfect code [ ;-) ], but I would have guessed that
Adding 10Ks of lines of code to the kernel would generate at least
some rejects].
Should we wait any longer before sending the next revision?
