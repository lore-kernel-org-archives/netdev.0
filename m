From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v6] net/hsr: Add support for the High-availability
 Seamless Redundancy protocol (HSRv0)
Date: Wed, 30 Oct 2013 13:15:22 -0700
Message-ID: <1383164122.9435.41.camel@joe-AO722>
References: <527167C7.4030305@xdin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Javier Boticario <jboticario@gmail.com>,
	"balferreira@googlemail.com" <balferreira@googlemail.com>,
	=?ISO-8859-1?Q?El=EDas?= Molina =?ISO-8859-1?Q?Mu=F1oz?=
	<elias.molina@ehu.es>
To: Arvid Brodin <arvid.brodin@xdin.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0051.hostedemail.com ([216.40.44.51]:37561 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752343Ab3J3UPZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Oct 2013 16:15:25 -0400
In-Reply-To: <527167C7.4030305@xdin.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-10-30 at 21:10 +0100, Arvid Brodin wrote:
> High-availability Seamless Redundancy ("HSR") provides instant failover
> redundancy for Ethernet networks. It requires a special network topology where
> all nodes are connected in a ring (each node having two physical network
> interfaces). It is suited for applications that demand high availability and
> very short reaction time.

Thanks Arvid.  Maybe add a MAINTAINERS entry too?
