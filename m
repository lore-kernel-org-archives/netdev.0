From: Christoph Raisch <RAISCH@de.ibm.com>
Subject: Re: [2.6.19 PATCH 3/7] ehea: queue management
Date: Fri, 18 Aug 2006 16:24:48 +0200
Message-ID: <OFC184057C.C58732A2-ONC12571CE.004E5EF6-C12571CE.004ED1D4@de.ibm.com>
References: <200608181547.47081.arnd.bergmann@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Arjan van de Ven <arjan@infradead.org>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linuxppc-dev@ozlabs.org, Marcus Eder <meder@de.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	Thomas Q Klein <tklein@de.ibm.com>, tklein@linux.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.de.ibm.com ([195.212.29.151]:40151 "EHLO
	mtagate2.de.ibm.com") by vger.kernel.org with ESMTP
	id S1030421AbWHROU6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Aug 2006 10:20:58 -0400
In-Reply-To: <200608181547.47081.arnd.bergmann@de.ibm.com>
To: abergman@de.ibm.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> You should really do some measurements to see what the minimal
> queue sizes are that can get you optimal throughput.
>
>    Arnd <><

we did.
And as always in performance tuning... one size fits all unfortunately is
not the correct answer.
Therefore we'll leave that open to the user as most other new ethernet
driver did as well.

Regards . . . Christoph R

