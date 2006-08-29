From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 08/10] [TULIP] Handle pci_enable_device() errors in resume
Date: Tue, 29 Aug 2006 16:46:32 -0400
Message-ID: <44F4A7A8.8050402@garzik.org>
References: <20060826000227.818796000@linux.intel.com> <20060826000304.251263000@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:21900 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S965303AbWH2Uqd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2006 16:46:33 -0400
To: Valerie Henson <val_henson@linux.intel.com>
In-Reply-To: <20060826000304.251263000@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ditto Alan's comments, particularly exiting w/out unlocking

