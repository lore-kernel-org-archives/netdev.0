From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 2.6.24]S2io: Default to IntA interrupt type when there are less than 4 CPUs in the system.
Date: 12 Aug 2007 19:15:38 +0200
Message-ID: <p73sl6oishx.fsf@bingen.suse.de>
References: <46BCA2B0.7020501@garzik.org>
	<78C9135A3D2ECE4B8162EBDCE82CAD7702035B30@nekter>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Jeff Garzik" <jeff@garzik.org>, "Rick Jones" <rick.jones2@hp.com>,
	"Sivakumar Subramani" <Sivakumar.Subramani@neterion.com>,
	<netdev@vger.kernel.org>, "support" <support@neterion.com>
To: "Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:43417 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762940AbXHLQVd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Aug 2007 12:21:33 -0400
In-Reply-To: <78C9135A3D2ECE4B8162EBDCE82CAD7702035B30@nekter>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com> writes:

> In one of the variations of this driver that is not
> released to netdev, the received packets are steered to a channel based
> on hashing on a preconfigured criteria such as sockets on tcp_ipv4,
> udp_ipv4, tcp_ipv6, udp_ipv6 or addresses in ipv4/6.

Why is it not released for mainline? It sounds interesting.

-Andi

