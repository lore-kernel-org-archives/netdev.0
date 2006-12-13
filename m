From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Subject: Re: [PATCH] eeprom_93cx6: Add write support
Date: Wed, 13 Dec 2006 14:06:51 -0500
Message-ID: <20061213190651.GF26412@csclub.uwaterloo.ca>
References: <200612131956.51000.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, Michael Wu <flamingice@sourmilk.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caffeine.uwaterloo.ca ([129.97.134.17]:39654 "EHLO
	caffeine.csclub.uwaterloo.ca" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S965078AbWLMTGv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Dec 2006 14:06:51 -0500
To: Ivo van Doorn <ivdoorn@gmail.com>
Content-Disposition: inline
In-Reply-To: <200612131956.51000.IvDoorn@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 13, 2006 at 07:56:50PM +0100, Ivo van Doorn wrote:
> This patch addes support for writing to the eeprom,
> this also moves some duplicate code into seperate functions.
> 
> Signed-off-by Ivo van Doorn <IvDoorn@gmail.com>

Thank you.  I will have a try with that to see if I can get that to work
with the jsm driver.  Too bad the serial drivers don't have any
geteeprom/seteeprom standard ioctl's the way ethtool does for network
devices.

--
Len Sorensen
