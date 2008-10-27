From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: [RFC PATCHv2] printk: add the %pM, %p4, %p6 format specifiers
Date: Sun, 26 Oct 2008 19:08:31 -0700
Message-ID: <4905229F.2090805@zytor.com>
References: <1224892008.3919.27.camel@johannes.berg> <49035AF0.6040700@anduras.de> <1225008096.3478.3.camel@johannes.berg> <20081026.010329.11475786.davem@davemloft.net> <1225009308.3478.22.camel@johannes.berg> <1225009822.3478.30.camel@johannes.berg> <1225047674.10060.10.camel@brick> <1225049591.3746.0.camel@johannes.berg> <1225049929.10060.11.camel@brick> <1225050015.3746.2.camel@johannes.berg> <1225060789.10060.13.camel@brick> <1225060789.10060.13.camel@brick> <1225067465.5672.1.camel@brick> <200810270221.08675.elendil@planet.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Harvey Harrison <harvey.harrison@gmail.com>,
	johannes@sipsolutions.net, davem@davemloft.net, anders@anduras.de,
	netdev@vger.kernel.org, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org
To: Frans Pop <elendil@planet.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from terminus.zytor.com ([198.137.202.10]:50694 "EHLO
	terminus.zytor.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751513AbYJ0CJH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Oct 2008 22:09:07 -0400
In-Reply-To: <200810270221.08675.elendil@planet.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Frans Pop wrote:
>> + * - '4' For a 4-byte IPv4 address, it prints the address in the
>> + *       usual colon-separated hex notation

Since when are IPv4 addresses "usually" printed in colon-separated hex?

	-hpa
