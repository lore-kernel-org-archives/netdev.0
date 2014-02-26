From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next v4 2/8] 6lowpan: add uncompress header size
 function
Date: Wed, 26 Feb 2014 10:35:52 -0800
Message-ID: <1393439752.407.33.camel@joe-AO722>
References: <1393430712-11298-1-git-send-email-alex.aring@gmail.com>
	 <1393430712-11298-3-git-send-email-alex.aring@gmail.com>
	 <063D6719AE5E284EB5DD2968C1650D6D0F6CBBCA@AcuExch.aculab.com>
	 <1393439085.407.31.camel@joe-AO722> <20140226183209.GA31268@omega>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@ACULAB.COM>,
	"alex.bluesman.smirnov@gmail.com" <alex.bluesman.smirnov@gmail.com>,
	"dbaryshkov@gmail.com" <dbaryshkov@gmail.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"linux-zigbee-devel@lists.sourceforge.net"
	<linux-zigbee-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"martin.townsend@xsilon.com" <martin.townsend@xsilon.com>
To: Alexander Aring <alex.aring@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0090.hostedemail.com ([216.40.44.90]:40021 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752089AbaBZSf4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Feb 2014 13:35:56 -0500
In-Reply-To: <20140226183209.GA31268@omega>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-02-26 at 19:32 +0100, Alexander Aring wrote:
> On Wed, Feb 26, 2014 at 10:24:45AM -0800, Joe Perches wrote:
[]
> > Perhaps the compiler would inline the assignment
> > anyway if addr_mode is __builtin_constant_p
[]
> I am not sure what I should do now, change or not change? :-)

Whatever you choose will be fine with me.
