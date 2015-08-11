From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel] [PATCH v3 0/9] Use correctly the Xen memory terminologies
Date: Tue, 11 Aug 2015 18:37:25 +0100
Message-ID: <55CA32D5.606@citrix.com>
References: <1438965282-19103-1-git-send-email-julien.grall@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-fbdev@vger.kernel.org>, <x86@kernel.org>,
	<netdev@vger.kernel.org>, "H. Peter Anvin" <hpa@zytor.com>,
	Jiri Slaby <jslaby@suse.com>,
	"Thomas Gleixner" <tglx@linutronix.de>,
	Russell King <linux@arm.linux.org.uk>,
	<linux-scsi@vger.kernel.org>,
	Tomi Valkeinen <tomi.valkeinen@ti.com>,
	<stefano.stabellini@eu.citrix.com>, Ingo Molnar <mingo@redhat.com>,
	<linux-input@vger.kernel.org>,
	Jean-Christophe Plagniol-Villard <plagnioj@jcrosoft.com>,
	<ian.campbell@citrix.com>,
	"James E.J. Bottomley" <JBottomley@odin.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	<linux-arm-kernel@lists.infradead.org>,
	Juergen Gross <jgross@suse.com>,
	"Wei Liu" <wei.liu2@citrix.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Dmitry Torokhov <dmitry.torokhov@gmail.com>,
	<linux-kernel@vger.kernel.org>,
	David Vrabel <david.vrabel@citrix.com>,
	<linux-api@vger.kernel.org>, <linuxppc-d
To: Julien Grall <julien.grall@citrix.com>,
	<xen-devel@lists.xenproject.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:45289 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751672AbbHKRhb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Aug 2015 13:37:31 -0400
In-Reply-To: <1438965282-19103-1-git-send-email-julien.grall@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/08/15 17:34, Julien Grall wrote:
> Hi all,
> 
> This patch series aims to use the memory terminologies described in
> include/xen/mm.h [1] for Linux xen code.

Applied to for-linus-4.3, thanks.

David
