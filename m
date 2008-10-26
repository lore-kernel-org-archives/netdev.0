From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: r8169 MAC addresses broken
Date: Sun, 26 Oct 2008 10:34:39 -0700
Message-ID: <20081026103439.7a60005a@infradead.org>
References: <490380C8.6070003@simon.arlott.org.uk>
	<4903947A.3060206@gmail.com>
	<20081025223443.GA30913@electric-eye.fr.zoreil.com>
	<4904A7C5.7090801@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Simon Arlott <simon@fire.lp0.eu>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Edward Hsu <edward_hsu@realtek.com.tw>,
	Ivan Vecera <ivecera@redhat.com>
To: Jiri Slaby <jirislaby@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:48265 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755773AbYJZReW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Oct 2008 13:34:22 -0400
In-Reply-To: <4904A7C5.7090801@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 26 Oct 2008 18:24:21 +0100
Jiri Slaby <jirislaby@gmail.com> wrote:

> On 10/26/2008 12:34 AM, Francois Romieu wrote:
> > It may go away if one comments out rtl_init_mac_address in
> > rtl8169_init_one
> 
> Hmm, no. How can one restore eeprom contents without making a brick
> from the notebook? I seem to have all zeroes in the eeprom mac
> address area. --

same here...  :(

-- 
Arjan van de Ven 	Intel Open Source Technology Centre
For development, discussion and tips for power savings, 
visit http://www.lesswatts.org
