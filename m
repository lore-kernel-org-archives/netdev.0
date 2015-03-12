From: Olaf Hering <olaf@aepfle.de>
Subject: Re: [PATCH 2/2 net-next] hyperv: Support batched notification
Date: Thu, 12 Mar 2015 12:06:28 +0100
Message-ID: <20150312110628.GC11353@aepfle.de>
References: <1426013383-2853-1-git-send-email-kys@microsoft.com>
 <1426013404-2892-1-git-send-email-kys@microsoft.com>
 <1426013404-2892-2-git-send-email-kys@microsoft.com>
 <20150311092354.GA13144@aepfle.de>
 <BY2PR0301MB07115FFD6E62E07CBAB0AED0A0190@BY2PR0301MB0711.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
	"apw@canonical.com" <apw@canonical.com>,
	"jasowang@redhat.com" <jasowang@redhat.com>
To: KY Srinivasan <kys@microsoft.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo4-p00-ob.smtp.rzone.de ([81.169.146.216]:22083 "EHLO
	mo4-p00-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753305AbbCLLGb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 07:06:31 -0400
Content-Disposition: inline
In-Reply-To: <BY2PR0301MB07115FFD6E62E07CBAB0AED0A0190@BY2PR0301MB0711.namprd03.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 11, KY Srinivasan wrote:

> This is the convention that we have used for patches submitted to
> David's tree.

I see, it refers to the directory name. In a bunch of backports it gives
the impression it affects the Hyper-V support as whole, while in fact a
given change is just for the network driver. Looks like I have to live
with that.

Olaf
