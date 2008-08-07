From: Jesse Barnes <jbarnes@virtuousgeek.org>
Subject: Re: [PATCH] PCI PM: Export pci_pme_active to drivers
Date: Thu, 7 Aug 2008 15:34:10 -0700
Message-ID: <200808071534.11482.jbarnes@virtuousgeek.org>
References: <200808051730.27599.alessandro.guido@gmail.com> <200808080000.07156.rjw@sisk.pl> <200808080014.25493.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Alessandro Guido <alessandro.guido@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	pm list <linux-pm@lists.linux-foundation.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outbound-mail-108.bluehost.com ([69.89.22.8]:35539 "HELO
	outbound-mail-108.bluehost.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752646AbYHGWeS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2008 18:34:18 -0400
In-Reply-To: <200808080014.25493.rjw@sisk.pl>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday, August 7, 2008 3:14 pm Rafael J. Wysocki wrote:
> PCI PM: Export pci_pme_active to drivers
>
> Export pci_pme_active() to drivers, so that they can clear the
> PME_status bit and disable PME# for their devices without involving
> ACPI.

Cool, applied.  Thanks Rafael.

Jesse
