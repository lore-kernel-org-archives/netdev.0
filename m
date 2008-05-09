From: Cornelia Huck <cornelia.huck@de.ibm.com>
Subject: Re: [PATCH 10/11] avoid kobject name conflict with different
 namespaces
Date: Fri, 9 May 2008 07:35:56 +0200
Message-ID: <20080509073556.3c342d14@gondolin.boeblingen.de.ibm.com>
References: <20080506173030.653828076@theryb.frec.bull.fr>
	<20080506173335.922289888@theryb.frec.bull.fr>
	<m13aoueyq8.fsf@frodo.ebiederm.org>
	<20080507190838.GA4467@suse.de>
	<m1hcd9esxo.fsf@frodo.ebiederm.org>
	<20080508102844.25642ef7@gondolin.boeblingen.de.ibm.com>
	<m1myn0d298.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Greg KH <gregkh@suse.de>, Benjamin Thery <benjamin.thery@bull.net>,
	linux-kernel@vger.kernel.org, Tejun Heo <htejun@gmail.com>,
	Al Viro <viro@ftp.linux.org.uk>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	"Serge E. Hallyn" <serue@us.ibm.com>,
	Pavel Emelyanov <xemul@openvz.org>, netdev@vger.kernel.org
To: ebiederm@xmission.com (Eric W. Biederman)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.uk.ibm.com ([195.212.29.140]:5045 "EHLO
	mtagate7.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932308AbYEIFgB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2008 01:36:01 -0400
In-Reply-To: <m1myn0d298.fsf@frodo.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 08 May 2008 12:28:19 -0700,
ebiederm@xmission.com (Eric W. Biederman) wrote:

> Do you remember if we have ever sorted out the race between _move
> and module unload/directory teardown at the sysfs level?

Unfortunately I can't remember anything about this, do you have a
pointer to the original discussion?
