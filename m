From: David Miller <davem@davemloft.net>
Subject: Re: Assertions in latest kernels
Date: Wed, 23 Jan 2008 02:57:32 -0800 (PST)
Message-ID: <20080123.025732.200278761.davem@davemloft.net>
References: <OF331AFFAC.CEF61228-ON652573D9.002CF47B-652573D9.002E0A84@in.ibm.com>
	<Pine.LNX.4.64.0801231043220.31652@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: krkumar2@in.ibm.com, netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60307
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751397AbYAWK5Y convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jan 2008 05:57:24 -0500
In-Reply-To: <Pine.LNX.4.64.0801231043220.31652@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Wed, 23 Jan 2008 11:17:05 +0200 (EET)

> What a strange thing that it has been super quiet on this front
> until now everybody is seeing it, could there be something unrelated
> to TCP which has broken it all recently?

I think it is simply "capture effect".

One person reports the problem, and then others see it and
say "me too" because they were previously too busy to report
their instance of the problem.

Another thing is that a developer is sometimes working on something
and they do not want to pollute the bug reporting if the code they are
writing is what is causing the bug via some indirect corruptions or
whatever :-)
