From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2/3] [2.6.26] ehea: Add dependency to Kconfig
Date: Tue, 03 Jun 2008 17:11:30 -0400
Message-ID: <4845B382.20205@garzik.org>
References: <200805071443.20192.hannes.hering@linux.vnet.ibm.com>	 <20080528164405.GA4836@localdomain>	 <200806031007.40162.hannes.hering@linux.vnet.ibm.com>	 <20080603204908.GB7475@localdomain> <1212527335.23656.2.camel@badari-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Nathan Lynch <ntl@pobox.com>,
	Hannes Hering <hannes.hering@linux.vnet.ibm.com>,
	tklein@de.ibm.com, themann@de.ibm.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, raisch@de.ibm.com,
	ossrosch@linux.vnet.ibm.com, linuxppc-dev@ozlabs.org,
	ossthema@de.ibm.com
To: Badari Pulavarty <pbadari@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:59743 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751429AbYFCVLw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Jun 2008 17:11:52 -0400
In-Reply-To: <1212527335.23656.2.camel@badari-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Badari Pulavarty wrote:
>> It would be nice to get this resolved for 2.6.26 -- this new
>> dependency causes working 2.6.25 configs to effectively fail (by
>> deselecting CONFIG_EHEA during make oldconfig).


When everybody else is happy, I'm happy :)

