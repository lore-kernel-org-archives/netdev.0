From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 0/5] of_platform_driver and OF_DEVICE removal
Date: Mon, 22 Apr 2013 09:03:54 +0200
Message-ID: <201304220903.54788.arnd@arndb.de>
References: <1366596798-9457-1-git-send-email-robherring2@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <rob.herring@calxeda.com>,
	Alexander Shishkin <alexander.shishkin@linux.intel.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Christoph Raisch <raisch@de.ibm.com>,
	"Greg Kroah-Hartman" <gregkh@linuxfoundation.org>,
	Hal Rosenstock <hal.rosenstock@gmail.com>,
	"Hoang-Nam Nguyen" <hnguyen@de.ibm.com>,
	linuxppc-dev@lists.ozlabs.org, linux-rdma@vger.kernel.org,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	Paul Mackerras <paulus@samba.org>,
	Roland Dreier <roland@kernel.org>,
	Sean Hefty <sean.hefty@intel.com>,
	Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
To: Rob Herring <robherring2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:60311 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752739Ab3DVHES (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Apr 2013 03:04:18 -0400
In-Reply-To: <1366596798-9457-1-git-send-email-robherring2@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 22 April 2013, Rob Herring wrote:
> From: Rob Herring <rob.herring@calxeda.com>
> 
> This series is a relatively straight-forward removal of the last remaining
> user of of_platform_driver (ibmebus) and removal of CONFIG_OF_DEVICE which
> is always enabled when CONFIG_OF is enabled.
> 
> Compile tested on powerpc and sparc.
> 

Acked-by: Arnd Bergmann <arnd@arndb.de>
