From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 2.6.19-rc3 1/2] ehea: kzalloc GFP_ATOMIC fix
Date: Thu, 26 Oct 2006 20:13:13 -0700
Message-ID: <20061026201313.9c831fc9.akpm@osdl.org>
References: <200610251311.43009.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, netdev <netdev@vger.kernel.org>,
	Christoph Raisch <raisch@de.ibm.com>,
	"Jan-Bernd Themann" <themann@de.ibm.com>,
	"linux-kernel" <linux-kernel@vger.kernel.org>,
	"linux-ppc" <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:11162 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1161478AbWJ0DOD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2006 23:14:03 -0400
To: Jan-Bernd Themann <ossthema@de.ibm.com>
In-Reply-To: <200610251311.43009.ossthema@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 25 Oct 2006 13:11:42 +0200
Jan-Bernd Themann <ossthema@de.ibm.com> wrote:

> This patch fixes kzalloc parameters (GFP_ATOMIC instead of GFP_KERNEL)

why?
