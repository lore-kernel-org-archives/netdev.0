From: John Rose <johnrose@austin.ibm.com>
Subject: Re: [PATCH] ehea: dynamic add / remove port
Date: Wed, 21 Feb 2007 11:02:58 -0600
Message-ID: <1172077378.22669.15.camel@sinatra.austin.ibm.com>
References: <200702211706.18235.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>,
	Christoph Raisch <RAISCH@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	Marcus Eder <MEDER@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>,
	Stefan Roscher <stefan.roscher@de.ibm.com>,
	netdev <netdev@vger.kernel.org>
To: Jan-Bernd Themann <ossthema@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:39557 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422699AbXBURF6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Feb 2007 12:05:58 -0500
In-Reply-To: <200702211706.18235.ossthema@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-02-21 at 10:06, Jan-Bernd Themann wrote:
> This patch introduces functionality to dynamically add / remove
> ehea ports via an userspace DLPAR tool. It creates a subnode for
> each logical port in the sysfs. 

Looks great!

Signed-off-by: Jan-Bernd Themann <themann@de.ibm.com>
Acked-by: John Rose <johnrose@austin.ibm.com>


