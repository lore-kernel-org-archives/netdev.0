From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH net-2.6.25 1/4] include - Convert IP4 address class macros	to
 inline functions
Date: Wed, 14 Nov 2007 08:53:13 -0800
Message-ID: <OF456A1240.FCBC428E-ON88257393.005C5D94-88257393.005CA64F@us.ibm.com>
References: <1195055603.5163.179.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: David Miller <davem@davemloft.net>,
	James Morris <jmorris@namei.org>,
	Patrick McHardy <kaber@coreworks.de>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	netdev <netdev@vger.kernel.org>, netdev-owner@vger.kernel.org,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:43160 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753416AbXKNQxi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 11:53:38 -0500
In-Reply-To: <1195055603.5163.179.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Maybe I'm more used to hex, but I personally don't think those are
more readable. It replaces 1-line macroes with 4-line functions, and
I think more vgrepping to pick out the relevant constant data.

                                                +-DLS

