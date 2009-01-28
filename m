From: Patrick McHardy <kaber@trash.net>
Subject: Re: port bound SAs
Date: Wed, 28 Jan 2009 19:11:52 +0100
Message-ID: <49809FE8.2040801@trash.net>
References: <F82446300569AC408EF6BC9E358737947EC12368@exch-one.centrify.com>	<BB7E16A14DE689469A181EC770AFBF4D02A773C1@exch-one.centrify.com> <20090126.222035.100955508.davem@davemloft.net> <497EE171.1030907@trash.net> <BB7E16A14DE689469A181EC770AFBF4D02A77515@exch-one.centrify.com> <497F3DD0.5010502@trash.net> <BB7E16A14DE689469A181EC770AFBF4D02A77722@exch-one.centrify.com> <49809DD5.6080104@trash.net> <BB7E16A14DE689469A181EC770AFBF4D02A7774E@exch-one.centrify.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Paul Moore <paul.moore@centrify.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:36998 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751095AbZA1SLy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2009 13:11:54 -0500
In-Reply-To: <BB7E16A14DE689469A181EC770AFBF4D02A7774E@exch-one.centrify.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Paul Moore wrote:
> So how do I get an SA with a port set on it

You don't, using pfkey. Use reqid or ip xfrm.
