From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2.6.19-rc1] ehea bug fix (port state notification, default
 queue sizes)
Date: Thu, 05 Oct 2006 07:30:14 -0400
Message-ID: <4524ECC6.2060201@garzik.org>
References: <200609281244.40887.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Christoph Raisch <raisch@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:35550 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1750749AbWJELaT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Oct 2006 07:30:19 -0400
To: Jan-Bernd Themann <ossthema@de.ibm.com>
In-Reply-To: <200609281244.40887.ossthema@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

which patch is to be applied first?

You failed to include an order, as described by 
http://linux.yyz.us/patch-format.html and Documentation/SubmittingPatches.

Also, stuff like "hi Jeff" and "Thanks, Jan-Bernd" must be hand-edited 
out before patch application.  All comments not intended to be DIRECTLY 
copied into the kernel changeset description should follow the "---" 
separator.

	Jeff



