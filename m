From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Subject: Re: [PATCH 04/26] rt2x00: EEPROM 93Cx6
Date: Wed, 13 Dec 2006 10:44:15 -0500
Message-ID: <20061213154415.GA26415@csclub.uwaterloo.ca>
References: <200612031919.05228.IvDoorn@gmail.com> <200612031339.28148.flamingice@sourmilk.net> <200612081956.14158.IvDoorn@gmail.com> <200612082100.14592.flamingice@sourmilk.net> <a32f33a40612090505j23251626k891edae1c06b6fb2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Wu <flamingice@sourmilk.net>,
	"John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from caffeine.uwaterloo.ca ([129.97.134.17]:59036 "EHLO
	caffeine.csclub.uwaterloo.ca" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S964919AbWLMQOi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Dec 2006 11:14:38 -0500
To: Ivo Van Doorn <ivdoorn@gmail.com>
Content-Disposition: inline
In-Reply-To: <a32f33a40612090505j23251626k891edae1c06b6fb2@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Dec 09, 2006 at 02:05:06PM +0100, Ivo Van Doorn wrote:
> Nope, don't have that device. I'll create a patch that will place the eeprom
> module in the /lib folder. I'll send that to the list as soon as possible.

Hmm, I wonder if this will be of help for me trying to read/write a
93c46 connected to an exar uart (jsm driver).  So far I was trying to
bit bang the IO from user space through the PCI registers, but having a
proper support in the driver would probably work better (so far I didn't
get it to work although I haven't tried very hard yet).

--
Len Sorensen
