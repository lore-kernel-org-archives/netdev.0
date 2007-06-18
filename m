From: Jan Engelhardt <jengelh@computergmbh.de>
Subject: Re: [PATCH] fix race in AF_UNIX
Date: Mon, 18 Jun 2007 13:45:19 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0706181344500.5731@fbirervta.pbzchgretzou.qr>
References: <E1I0BzQ-0006gZ-00@dorka.pomaz.szeredi.hu>
 <20070618.005711.21897961.davem@davemloft.net> <E1I0CTH-0006k3-00@dorka.pomaz.szeredi.hu>
 <20070618.021813.105401188.davem@davemloft.net> <E1I0DYW-0006uZ-00@dorka.pomaz.szeredi.hu>
 <20070618124721.56411b93@the-village.bc.nu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Miklos Szeredi <miklos@szeredi.hu>, davem@davemloft.net,
	akpm@linux-foundation.org, viro@ftp.linux.org.uk,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:24306 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754264AbXFRLpU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2007 07:45:20 -0400
In-Reply-To: <20070618124721.56411b93@the-village.bc.nu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Jun 18 2007 12:47, Alan Cox wrote:
>
>> Do you want me to send the patch to Andrew instead?  His attitude
>> towards bugfixes is rather better ;)
>
>And it'll get NAKked and binned. DaveM is (as happens sometimes ;)) right
>to insist on the code being clean and efficient.

Or see RFC 1925 number 7a. :)


	Jan
-- 
