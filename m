From: Brian S Julin <BJulin@clarku.edu>
Subject: RE: routing policy based on u32 classifier
Date: Mon, 10 Dec 2007 09:57:30 -0500
Message-ID: <5A630F46702DD1498FFD48394B4A664C347275DD@john.ad.clarku.edu>
References: <BAY103-DAV51710C05B584C53DED66DB26B0@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: Marco Berizzi <pupilla@hotmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from george.clarku.edu ([140.232.1.173]:56788 "EHLO
	george.george.clarku.edu" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753109AbXLJO5d convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Dec 2007 09:57:33 -0500
In-Reply-To: <BAY103-DAV51710C05B584C53DED66DB26B0@phx.gbl>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Marco wrote:

> Hello everybody.
> Kindly, I would like to know if the is any plan to add this feature to a future kernel release.
> I know that fwmark is able to do this, but there is the limitation in source ip address selection.

Could you explain the limitation?  My iptables manpage seems to suggest
that u32 is pretty general.  Are you just asking if the pom-ng ipt_u32
will be mainlined?

