From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 0/4] ehea: IBM eHEA Ethernet Device Driver
Date: Wed, 7 Jun 2006 10:24:15 -0700
Message-ID: <20060607102415.74fb0cd7@localhost.localdomain>
References: <4486ECED.9080608@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, raisch@de.ibm.com, themann@de.ibm.com,
	tklein@de.ibm.com, meder@de.ibm.com, schickhj@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:43659 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932357AbWFGRYa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jun 2006 13:24:30 -0400
To: Jan-Bernd Themann <ossthema@de.ibm.com>
In-Reply-To: <4486ECED.9080608@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 07 Jun 2006 17:12:45 +0200
Jan-Bernd Themann <ossthema@de.ibm.com> wrote:

> Hello,
> 
> this is the first version of the IBM eHEA Ethernet Device Driver.
> It supports a new IBM ethernet chip on System p.
> 
> Main functionality including broadcast multicast and some parts of
> ethtool already work.
> 
> Things we're still working on:
> - vlan support
> - performance improvements in SMP systems
> - kernel coding style

Please:
   - Get rid of the debug macro's with 9 arguments...

