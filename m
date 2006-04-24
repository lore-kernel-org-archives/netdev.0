From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH wireless-2.6] add adm8211 wireless driver
Date: Mon, 24 Apr 2006 17:13:45 -0400
Message-ID: <20060424211340.GE21761@tuxdriver.com>
References: <444026BF.2080801@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Michael Wu <flamingice@sourmilk.net>,
	Jouni Malinen <jkmaline@cc.hut.fi>,
	Jean Tourrilhes <jt@hpl.hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([24.172.12.4]:45326 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1751214AbWDXVUT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2006 17:20:19 -0400
To: "Luis R. Rodriguez" <mcgrof@gmail.com>
Content-Disposition: inline
In-Reply-To: <444026BF.2080801@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 14, 2006 at 06:48:31PM -0400, Luis R. Rodriguez wrote:
> 
> John, (Jean please update your docs)
> 
> as promised here's a new 802.11b driver for wireless-2.6. It is based on
> Jouni Malinen's original work and maintained by Michael Wu.
> This driver is for ADM8211A, ADM8211B, and ADM8211C based cards which
> are PCI/mini-PCI/Cardbus 802.11b cards. This driver has been tested and
> known to work with the following wireless cards:

Applied to master branch of wireless-2.6.  Let's get this one properly
reviewed and whipped into shape in time for 2.6.18!

John
-- 
John W. Linville
linville@tuxdriver.com
